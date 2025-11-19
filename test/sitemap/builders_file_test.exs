defmodule Sitemaps.BuildersFileTest do
  use ExUnit.Case

  setup do
    Sitemaps.Builders.File.stop()
    Sitemaps.Builders.IndexFile.stop()
    Sitemaps.Namer.stop(:file)
    Sitemaps.Namer.stop(:index_file)
  end

  test "Add Builders.File" do
    data = [lastmod: "lastmod", expires: "expires", changefreq: "changefreq", priority: 0.5]
    assert :ok == Sitemaps.Builders.File.add("", data)
  end

  test "Adds Builders.File" do
    data = [lastmod: "lastmod", expires: "expires", changefreq: "changefreq", priority: 0.5]
    Enum.each(1..10, fn _ -> Sitemaps.Builders.File.add("", data) end)

    assert 10 == Sitemaps.Builders.File.state().link_count
  end
end
