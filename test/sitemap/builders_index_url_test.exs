defmodule Sitemaps.BuildersIndexUrlTest do
  use ExUnit.Case

  setup do
    Sitemaps.Builders.File.stop()
    Sitemaps.Builders.IndexFile.stop()
    Sitemaps.Namer.stop(:file)
    Sitemaps.Namer.stop(:index_file)
  end
end
