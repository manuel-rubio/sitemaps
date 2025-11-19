defmodule Sitemaps.Builders.Url do
  @moduledoc """
  Create the _url_ tag adding all of the information that could be
  passed via attributes to the function `to_xml/2` as second parameter.
  """
  import XmlBuilder

  alias Sitemaps.Config
  alias Sitemaps.Func

  @doc """
  It creates the XML representation of a link based on the attributes
  passed as second parameter. You can use as parameters:

  - `:lastmod` as the time it was modified last time. See `Sitemaps.Func.iso8601/0`.
  - `:expires` as the number of seconds when it will expire.
  - `:changefreq` as the frequency of changing of the link.
  - `:priority` as the number of the priority of the link.
  - `:mobile`
  - `:geo`
  - `:pagemap`
  - `:images`
  - `:videos`
  - `:alternates`
  """
  def to_xml(link, attrs \\ []) do
    elements =
      []
      |> maybe_add_element(:loc, Path.join(Config.get().host, link || ""))
      |> maybe_add_element(
        :lastmod,
        Func.iso8601(Keyword.get_lazy(attrs, :lastmod, fn -> Func.iso8601() end))
      )
      |> maybe_add_element(:expires, attrs[:expires])
      |> maybe_add_element(:changefreq, attrs[:changefreq])
      |> maybe_add_element(:priority, attrs[:priority])
      |> maybe_add(attrs[:mobile], &[mobile() | &1])
      |> maybe_add(attrs[:geo], &[geo(attrs[:geo]) | &1])
      |> maybe_add(attrs[:news], &[news(attrs[:news]) | &1])
      |> maybe_add(attrs[:pagemap], &[pagemap(attrs[:pagemap]) | &1])
      |> maybe_add(attrs[:images], &[images(attrs[:images]) | &1])
      |> maybe_add(attrs[:videos], &[videos(attrs[:videos]) | &1])
      |> maybe_add(attrs[:alternates], &[alternates(attrs[:alternates]) | &1])
      |> pack_elements()

    element(:url, elements)
  end

  defp add_element(elements, name, attrs \\ %{}, children) do
    [element(name, attrs, children) | elements]
  end

  defp maybe_add(elements, nil, _fun), do: elements
  defp maybe_add(elements, _condition, f), do: f.(elements)

  defp maybe_add_element(elements, key, value, attrs \\ %{}, children \\ [])

  defp maybe_add_element(elements, _key, nil, _attrs, _children), do: elements

  defp maybe_add_element(elements, key, value, attrs, children) when is_list(children) do
    [element(key, attrs, if(children == [], do: value, else: children)) | elements]
  end

  defp news(data) do
    news_elements =
      []
      |> add_element(
        :"news:publication",
        []
        |> add_element(:"news:name", data[:publication_name])
        |> add_element(:"news:language", data[:publication_language])
        |> pack_elements()
      )
      |> maybe_add_element(:"news:title", data[:title])
      |> maybe_add_element(:"news:access", data[:access])
      |> maybe_add_element(:"news:genres", data[:genres])
      |> maybe_add_element(:"news:keywords", data[:keywords])
      |> maybe_add_element(:"news:stock_tickers", data[:stock_tickers])
      |> maybe_add_element(:"news:publication_date", Func.iso8601(data[:publication_date]))
      |> pack_elements()

    element(:"news:news", news_elements)
  end

  defp images(list, elements \\ [])
  defp images([], elements), do: elements

  defp images([{_, _} | _] = list, elements) do
    # Make sure keyword list
    images([list], elements)
  end

  defp images([data | tail], elements) do
    image_elements =
      []
      |> maybe_add_element(:"image:loc", data[:loc])
      |> maybe_add_element(:"image:title", data[:title])
      |> maybe_add_element(:"image:license", data[:license])
      |> maybe_add_element(:"image:caption", data[:caption])
      |> maybe_add_element(:"image:geo_location", data[:geo_location])
      |> pack_elements()

    images(tail, elements ++ [element(:"image:image", image_elements)])
  end

  defp pack_elements(elements) do
    elements
    |> Enum.reverse()
    |> Func.eraser()
  end

  defp videos(list, elements \\ [])
  defp videos([], elements), do: elements

  defp videos([{_, _} | _] = list, elements) do
    # Make sure keyword list
    videos([list], elements)
  end

  defp videos([data | tail], elements) do
    video_elements =
      []
      |> maybe_add_element(:"video:title", data[:title])
      |> maybe_add_element(:"video:description", data[:description])
      |> maybe_add_element(:"video:player_loc", data[:player_loc], %{
        allow_embed: Func.yes_no(data[:allow_embed]),
        autoplay: Func.autoplay(data[:autoplay])
      })
      |> maybe_add_element(:"video:content_loc", data[:content_loc])
      |> maybe_add_element(:"video:thumbnail_loc", data[:thumbnail_loc])
      |> maybe_add_element(:"video:duration", data[:duration])
      |> maybe_add_element(:"video:gallery_loc", data[:gallery_loc], %{
        title: data[:gallery_title]
      })
      |> maybe_add_element(:"video:rating", data[:rating])
      |> maybe_add_element(:"video:view_count", data[:view_count])
      |> maybe_add_element(:"video:expiration_date", Func.iso8601(data[:expiration_date]))
      |> maybe_add_element(:"video:publication_date", Func.iso8601(data[:publication_date]))
      |> then(fn attrs ->
        Enum.reduce(data[:tags] || [], attrs, fn tag, acc ->
          maybe_add_element(acc, :"video:tag", tag)
        end)
      end)
      |> maybe_add_element(:"video:tag", data[:tag])
      |> maybe_add_element(:"video:category", data[:category])
      |> maybe_add_element(:"video:family_friendly", Func.yes_no(data[:family_friendly]))
      |> maybe_add_element(:"video:restriction", data[:restriction], %{
        relationship: Func.allow_deny(data[:relationship])
      })
      |> maybe_add_element(:"video:uploader", data[:uploader], %{
        info: data[:uploader_info]
      })
      |> maybe_add_element(:"video:price", data[:price], video_price_attrs(data))
      |> maybe_add_element(:"video:live", Func.yes_no(data[:live]))
      |> maybe_add_element(
        :"video:requires_subscription",
        Func.yes_no(data[:requires_subscription])
      )
      |> pack_elements()

    videos(tail, elements ++ [element(:"video:video", video_elements)])
  end

  defp video_price_attrs(data) do
    %{currency: data[:price_currency]}
    |> maybe_add(data[:price_type], &Map.put(&1, :type, data[:price_type]))
    |> maybe_add(data[:price_resolution], &Map.put(&1, :resolution, data[:price_resolution]))
  end

  defp alternates(list, elements \\ [])
  defp alternates([], elements), do: elements

  defp alternates([{_, _} | _] = list, elements) do
    # Make sure keyword list
    alternates([list], elements)
  end

  defp alternates([data | tail], elements) do
    rel = if data[:nofollow], do: "alternate nofollow", else: "alternate"

    attrs = %{rel: rel, href: data[:href]}
    attrs = Map.put(attrs, :hreflang, data[:lang])
    attrs = Map.put(attrs, :media, data[:media])

    alternates(tail, elements ++ [element(:"xhtml:link", attrs)])
  end

  defp geo(data) do
    element(:"geo:geo", [
      element(:"geo:format", data[:format])
    ])
  end

  defp mobile, do: element(:"mobile:mobile", [])

  defp pagemap(data) do
    element(
      :PageMap,
      Enum.map(data[:dataobjects] || [], fn obj ->
        element(
          :DataObject,
          %{type: obj[:type], id: obj[:id]},
          Enum.map(obj[:attributes] || [], fn attr ->
            element(:Attribute, %{name: attr[:name]}, attr[:value])
          end)
        )
      end)
    )
  end
end
