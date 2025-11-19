defmodule Sitemaps.Consts do
  @moduledoc """
  Define the information needed to generate XML. Here you can find the schemas,
  the XML header, XML footer, and same header and footer for XML indexes.
  """

  @doc """
  The schemas we will need for XML sitemap.
  """
  @spec schemas :: %{atom() => String.t()}
  def schemas do
    %{
      geo: "http://www.google.com/geo/schemas/sitemap/1.0",
      news: "http://www.google.com/schemas/sitemap-news/0.9",
      image: "http://www.google.com/schemas/sitemap-image/1.1",
      video: "http://www.google.com/schemas/sitemap-video/1.1",
      mobile: "http://www.google.com/schemas/sitemap-mobile/1.0",
      pagemap: "http://www.google.com/schemas/sitemap-pagemap/1.0"
    }
  end

  @doc """
  The header in use for the sitemap file.
  """
  @spec xml_header :: String.t()
  def xml_header do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset
      xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
        http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
      xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'
      xmlns:geo='http://www.google.com/geo/schemas/sitemap/1.0'
      xmlns:news='http://www.google.com/schemas/sitemap-news/0.9'
      xmlns:image='http://www.google.com/schemas/sitemap-image/1.1'
      xmlns:video='http://www.google.com/schemas/sitemap-video/1.1'
      xmlns:mobile='http://www.google.com/schemas/sitemap-mobile/1.0'
      xmlns:pagemap='http://www.google.com/schemas/sitemap-pagemap/1.0'
      xmlns:xhtml='http://www.w3.org/1999/xhtml'
    >
    """
  end

  @doc """
  The footer (or closing tag) for the XML sitemap.
  """
  @spec xml_footer :: String.t()
  def xml_footer, do: "</urlset>"

  @doc """
  The header for the index file.
  """
  @spec xml_index_header :: String.t()
  def xml_index_header do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <sitemapindex
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
        http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd"
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
    >
    """
  end

  @doc """
  The footer for the index file.
  """
  @spec xml_index_footer :: String.t()
  def xml_index_footer, do: "</sitemapindex>"
end
