defmodule Sitemaps.Namer do
  @moduledoc """
  Names generated for the sitemap files.
  """
  alias Sitemaps.Config
  alias Sitemaps.NameError

  use Sitemaps.State,
    ext: ".xml.gz",
    zero: nil,
    start: 1,
    count: nil

  @doc """
  Get the name of the filename given the `:file`, `:index_file`, or a string.
  """
  def to_string(name) do
    s = state(name)
    "#{Config.get().filename}#{s.count}#{s.ext}"
  end

  @doc """
  Restart the naming for the sitemap and index files.
  """
  def reset(name) do
    update_state(name, :count, state(name).zero)
  end

  @doc """
  Returns true if it's still in the first (0) file, otherwise false.
  """
  def start?(name) do
    s = state(name)
    s.count == s.zero
  end

  @doc """
  Generate a new file.
  """
  def next(name) do
    if start?(name) do
      update_state(name, :count, state(name).start)
    else
      incr_state(name, :count)
    end
  end

  @doc """
  Goes to the previous file. It generates an error if it's
  not started, see `start?/1`.
  """
  def previous!(name) do
    if start?(name),
      do:
        raise(NameError,
          message: "Already at the start of the series"
        )

    s = state(name)

    if s.count <= s.start do
      update_state(name, :count, state(name).zero)
    else
      decr_state(name, :count)
    end
  end
end
