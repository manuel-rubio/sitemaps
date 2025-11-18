defmodule Sitemap.Builders.IndexFile do
  @moduledoc """
  Creates a index file for the number of files containing the sitemaps.
  """
  alias Sitemap.Builders.File, as: FileBuilder
  alias Sitemap.Builders.IndexUrl
  alias Sitemap.Consts
  alias Sitemap.Location

  require XmlBuilder

  use Sitemap.State,
    content: "",
    link_count: 0,
    total_count: 0

  @doc """
  Add the file in use in `Location` to the index_file. The options
  are passed to `Sitemap.Builders.IndexUrl.to_xml/2` as second parameter,
  you can check there which options can be used. By default, no options
  are needed.
  """
  def add(options \\ []) do
    FileBuilder.write()

    content =
      IndexUrl.to_xml(Location.url(:file), options)
      |> XmlBuilder.generate()

    add_state(:content, content)
    incr_state(:link_count)
    incr_state(:total_count, FileBuilder.state().link_count)
  end

  @doc """
  Add a link directly through the index file. See `add/1`.
  """
  def add(link, options) do
    content =
      IndexUrl.to_xml(Location.url(link), options)
      |> XmlBuilder.generate()

    # TODO: Count-Up sitemap line.

    add_state(:content, content)
  end

  @doc """
  Write the index file.
  """
  def write do
    content = Consts.xml_index_header() <> state().content <> Consts.xml_index_footer()
    Sitemap.File.write(:index_file, content)
  end
end
