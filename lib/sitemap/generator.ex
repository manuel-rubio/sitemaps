defmodule Sitemap.Generator do
  @moduledoc """
  Generator provides functions for generate the sitemap file.
  """
  alias Sitemap.Builders.File, as: FileBuilder
  alias Sitemap.Builders.IndexFile
  alias Sitemap.Location
  alias Sitemap.Namer

  @doc """
  Add a link to the sitemap file. See `Sitemap.Builders.File.add/2`.
  """
  def add(link, attrs \\ []) do
    if FileBuilder.add(link, attrs) == :full do
      full()
      add(link, attrs)
    else
      :ok
    end
  end

  @doc """
  Add a link to the index file. See `Sitemap.Builders.IndexFile.add/2`.
  """
  def add_to_index(link, options \\ []) do
    IndexFile.add(link, options)
  end

  @doc """
  Add index file and stop the sitemap file.
  """
  def full do
    IndexFile.add()
    FileBuilder.stop()
  end

  @doc """
  Perform the running of `full/0` and then `reset/0`.
  """
  def fin do
    full()
    reset()
  end

  @doc """
  Write the index file, and stop it. It performs an update to the namer
  sitemap file.
  """
  def reset do
    IndexFile.write()
    IndexFile.stop()
    Namer.update_state(:file, :count, nil)
  end

  @doc """
  Performs a ping to Google, and Bing, for starting the indexing.
  """
  def ping(urls \\ []) do
    urls = ~w(http://google.com/ping?sitemap=%s
              http://www.bing.com/webmaster/ping.aspx?sitemap=%s) ++ urls

    index_url = Location.url(:index_file)

    spawn(fn ->
      Enum.each(urls, fn url ->
        ping_url = String.replace(url, "%s", index_url)

        :httpc.request(to_charlist(ping_url))
        IO.puts("Successful ping of #{ping_url}")
      end)
    end)
  end
end
