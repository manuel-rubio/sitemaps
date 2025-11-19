defmodule Sitemaps.Builders.IndexFile do
  @moduledoc """
  Creates a index file for the number of files containing the sitemaps.
  """
  alias Sitemaps.Builders.File, as: FileBuilder
  alias Sitemaps.Builders.IndexUrl
  alias Sitemaps.Consts
  alias Sitemaps.Location

  require XmlBuilder

  use Sitemaps.State,
    content: "",
    link_count: 0,
    total_count: 0

  @doc """
  Add the file in use in `Location` to the index_file. The options
  are passed to `Sitemaps.Builders.IndexUrl.to_xml/2` as second parameter,
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
    Sitemaps.File.write(:index_file, content)
  end
end
