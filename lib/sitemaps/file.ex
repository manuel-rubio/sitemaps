defmodule Sitemaps.File do
  @moduledoc """
  Perform the write of the file.
  """
  alias Sitemaps.DirNotExists
  alias Sitemaps.Location

  @doc """
  Write the content of the file given the name.
  """
  def write(name, data) do
    dir = Location.directory()

    cond do
      not File.exists?(dir) -> File.mkdir_p(dir)
      not File.dir?(dir) -> raise DirNotExists
      :else -> nil
    end

    path = Location.path(name)

    if Regex.match?(~r/.gz$/, path) do
      File.write!(path, data, [:write, :utf8, :compressed])
    else
      File.write!(path, data, [:write, :utf8])
    end
  end
end
