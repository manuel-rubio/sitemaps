defmodule Sitemaps do
  @moduledoc """
  Sitemap application is in charge of running the supervisor and the following
  processes under it:

  - `Sitemaps.Config`
  - `Sitemaps.Builders.File`
  - `Sitemaps.Builders.IndexFile`
  - `Sitemaps.Namer`
    - `:namer_index_file`
    - `:namer_file`
  """
  use Application

  @doc false
  @impl true
  def start(_type, _args) do
    children = [
      Sitemaps.Config,
      Sitemaps.Builders.File,
      Sitemaps.Builders.IndexFile,
      %{
        id: :namer_index_file,
        start: {Sitemaps.Namer, :start_link, [:index_file]}
      },
      %{
        id: :namer_file,
        start: {Sitemaps.Namer, :start_link, [:file, [zero: 1, start: 2]]}
      }
    ]

    opts = [strategy: :one_for_all, name: Sitemaps.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc false
  defmacro __using__(opts) do
    quote do
      use Sitemaps.DSL, unquote(opts)
    end
  end
end
