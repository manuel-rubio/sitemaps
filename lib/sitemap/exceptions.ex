defmodule Sitemap.DirNotExists do
  @moduledoc """
  When the directory where a file will be written doesn't exist, this
  error will be triggered.
  """

  defexception message: "no message"
end

defmodule Sitemap.NameError do
  @moduledoc """
  This error is triggered when `Sitemap.Namer.previous!/1` function
  is called but it's the located in the first file.
  """
  defexception message: "no message"
end
