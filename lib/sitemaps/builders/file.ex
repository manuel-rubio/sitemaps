defmodule Sitemaps.Builders.File do
  @moduledoc """
  Build the file content of the sitemap. It creates the file and
  it's in charge of the size, if it's growing over the configured
  size, it's creating a new file.
  """
  alias Sitemaps.Builders.Url
  alias Sitemaps.Config
  alias Sitemaps.Consts
  alias Sitemaps.Location

  require XmlBuilder

  use Sitemaps.State,
    link_count: 0,
    news_count: 0,
    content: "",
    content_size: 0

  defp size_limit?(content) do
    size = byte_size(content)
    incr_state(:content_size, size)

    cfg = Config.get()
    s = state()

    size + s.content_size < cfg.max_sitemap_file_size and
      s.link_count < cfg.max_sitemap_links and
      s.news_count < cfg.max_sitemap_news
  end

  @doc """
  Add a link inside of the file. The `link` attribute must be a valid link
  for accessing to a page in the website and we could add some attributes.
  """
  # TODO add doc about the attrs we could use
  def add(link, attrs \\ []) do
    content =
      Url.to_xml(link, attrs)
      |> XmlBuilder.generate()

    if size_limit?(content) do
      add_state(:content, content)
      incr_state(:link_count)
    else
      :full
    end
  end

  @doc """
  Write the file in the XML format for the sitemap. First step is reserve
  a new name and then perform the writing of the links accumulated in the
  state.
  """
  def write do
    content = Consts.xml_header() <> state().content <> Consts.xml_footer()

    Location.reserve_name(:file)
    Sitemaps.File.write(:file, content)
  end
end
