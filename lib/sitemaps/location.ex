defmodule Sitemaps.Location do
  @moduledoc """
  Location is a facility for giving the path and filename for the sitemap file
  and the index file.
  """
  alias Sitemaps.Config
  alias Sitemaps.Namer

  @doc """
  Get the directory, the _files_path_ from the configuration and expand it
  to get the absolute path.
  """
  def directory do
    Config.get().files_path
    |> Path.expand()
  end

  @doc """
  Get the full path for the file passed as parameter.
  """
  def path(name) do
    Config.get().files_path
    |> Path.join(filename(name))
    |> Path.expand()
  end

  @doc """
  Get the URL for the specific sitemap or index files. The parameter expects
  or `:file` or `:index_file` or a string with the name of the file.
  """
  def url(name) when is_atom(name) do
    s = Config.get()

    s.host
    |> Path.join(s.public_path)
    |> Path.join(filename(name))
  end

  def url(link) when is_binary(link) do
    Config.get().host
    |> Path.join(link)
  end

  @doc """
  Get the filename given the name.
  """
  def filename(name) do
    filename = Namer.to_string(name)

    if Config.get().compress do
      filename
    else
      Regex.replace(~r/\.gz$/, filename, "")
    end
  end

  @doc """
  Get a new filename.
  """
  def reserve_name(name) do
    filename = filename(name)
    Namer.next(name)
    filename
  end
end
