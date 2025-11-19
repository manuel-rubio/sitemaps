defmodule Sitemaps.Builders.IndexUrl do
  @moduledoc """
  It has only one function to convert to XML a link.
  Indeed, it's creating a _sitemap_ tag that's returned
  to be included inside of a sitemap file.
  """
  alias Sitemaps.Func
  import XmlBuilder

  @doc """
  Get the link and creates a sitemap file. The options you
  can pass as second parameter optionally are:

  - `host` as the name of the host that will appear in the _loc_ tag
    inside of _sitemap_ tag.
  - `lastmod` as the date in ISO-8601 that will appear in the _lastmod_
    tag inside of the _sitemap_ tag.
  """
  def to_xml(link, opts \\ []) do
    element(
      :sitemap,
      Func.eraser([
        element(:loc, if(opts[:host], do: Func.url_join(link, opts[:host]), else: link)),
        element(:lastmod, Keyword.get_lazy(opts, :lastmod, fn -> Func.iso8601() end))
      ])
    )
  end
end
