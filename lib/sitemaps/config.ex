defmodule Sitemaps.Config do
  @moduledoc """
  Configuration for the generation of the sitemap. Here we define some values
  that are going to be in use for the sitemap files or index files but we
  cannot add in the individual adds, i.e. hostname.

  In addition, we define here some configuration for the maximum number of
  files, links, news, images, and sizes.
  """
  use Agent, restart: :transient
  import Sitemaps.Func, only: [get_env: 1]

  @typedoc """
  The configuration struct contains the following data:

  - `max_sitemap_files`: max sitemap links per index file.
  - `max_sitemap_links`: max links per sitemap.
  - `max_sitemap_news`: max news sitemap per index file.
  - `max_sitemap_images`: max images per URL.
  - `max_sitemap_file_size`: max sitemap file size in bytes.
  - `host`: your domain, also host with http/https scheme.
  - `filename`: name of the sitemap file.
  - `public_path`: after domain path's location on URL.
  - `files_path`: generating sitemaps to this directory path.
  - `verbose`: give more output for each step or not.
  - `compress`: if the sitemap files and indexes should be compressed.
  - `create_index`: if we need to create index files or not.
  """
  @type t() :: %__MODULE__{
          max_sitemap_files: pos_integer(),
          max_sitemap_links: pos_integer(),
          max_sitemap_news: pos_integer(),
          max_sitemap_images: pos_integer(),
          max_sitemap_file_size: pos_integer(),
          host: String.t(),
          filename: String.t(),
          public_path: String.t(),
          files_path: String.t(),
          verbose: boolean(),
          compress: boolean(),
          create_index: boolean()
        }

  @type keys() ::
          :max_sitemap_files
          | :max_sitemap_links
          | :max_sitemap_news
          | :max_sitemap_images
          | :max_sitemap_file_size
          | :host
          | :filename
          | :public_path
          | :files_path
          | :verbose
          | :compress
          | :create_index

  defstruct [
    :max_sitemap_files,
    :max_sitemap_links,
    :max_sitemap_news,
    :max_sitemap_images,
    :max_sitemap_file_size,
    :host,
    :filename,
    :public_path,
    :files_path,
    :verbose,
    :compress,
    :create_index
  ]

  @doc false
  def start_link([]), do: configure(nil)

  def start_link(value) do
    Agent.start_link(fn -> value end, name: __MODULE__)
  end

  defp get_cfg(base, key, env_key, default) do
    base[key] ||
      get_env(env_key) ||
      Application.get_env(:sitemaps, key, default)
  end

  @doc """
  Set the configuration from default source. It's first trying to get
  from system environment variables and if they are not set, then from
  application configuration.
  """
  # TODO the order makes no sense, it should be first application configuration.
  def configure, do: configure(nil)

  @doc """
  Let's configure the values of the configuration via the first parameter.
  If we pass `nil` then it's using `configure/0`. The order of the
  configuration is: parameter, or system environment variable, or
  configuration from the application.

  The environment variables you can set:

  - `SITEMAPS_MAXFILES` for `:max_sitemap_files`, default value: 10_000
  - `SITEMAPS_MAXLINKS` for `:max_sitemap_links`, default value: 10_000
  - `SITEMAPS_MAXNEWS` for `:max_sitemap_news`, default value: 1_000
  - `SITEMAPS_MAXIMAGES` for `:max_sitemap_images`, default value: 1_000
  - `SITEMAPS_MAXFILESIZE` for `:max_sitemap_file_size`, default value: 5_000_000
  - `SITEMAPS_HOST` for `:host`, default value: "http://www.example.com"
  - `SITEMAPS_FILENAME` for `:filename`, default value: "sitemap"
  - `SITEMAPS_SITEMAPS_PATH` for `:files_path`, default value: "sitemaps/"
  - `SITEMAPS_PUBLIC_PATH` for `:public_path`, default value: "sitemaps/"
  - `SITEMAPS_VERBOSE` for `:verbose`, default value: true
  - `SITEMAPS_COMPRESS` for `:compress`, default value: true
  - `SITEMAPS_CREATE_INDEX` for `:create_index`, default value: "auto"
  """
  # TODO the order makes no sense, it should be second application configuration.
  def configure(overwrite) do
    start_link(%__MODULE__{
      max_sitemap_files: get_cfg(overwrite, :max_sitemap_files, "SITEMAPS_MAXFILES", 10_000),
      max_sitemap_links: get_cfg(overwrite, :max_sitemap_links, "SITEMAPS_MAXLINKS", 10_000),
      max_sitemap_news: get_cfg(overwrite, :max_sitemap_news, "SITEMAPS_MAXNEWS", 1_000),
      max_sitemap_images: get_cfg(overwrite, :max_sitemap_images, "SITEMAPS_MAXIMAGES", 1_000),
      max_sitemap_file_size:
        get_cfg(overwrite, :max_sitemap_file_size, "SITEMAPS_MAXFILESIZE", 5_000_000),
      host: get_cfg(overwrite, :host, "SITEMAPS_HOST", "http://www.example.com"),
      filename: get_cfg(overwrite, :filename, "SITEMAPS_FILENAME", "sitemap"),
      files_path: get_cfg(overwrite, :files_path, "SITEMAPS_SITEMAPS_PATH", "sitemaps/"),
      public_path: get_cfg(overwrite, :public_path, "SITEMAPS_PUBLIC_PATH", "sitemaps/"),
      verbose: get_cfg(overwrite, :verbose, "SITEMAPS_VERBOSE", true),
      compress: get_cfg(overwrite, :compress, "SITEMAPS_COMPRESS", true),
      create_index: get_cfg(overwrite, :create_index, "SITEMAPS_CREATE_INDEX", "auto")
    })
  end

  @doc """
  Get the configuration from the agent where we have it stored.
  """
  def get do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Set the configuration inside of the agent.
  """
  @spec set(keys(), any()) :: :ok
  def set(key, value) do
    Agent.update(__MODULE__, fn config ->
      Map.update!(config, key, fn _ -> value end)
    end)
  end

  @doc """
  Passing as first parameter a list of tuples, we use `set/2` for setting
  each pair of key-value data from the `overwrite` parameter.
  """
  @spec update([{keys(), any()}]) :: :ok
  def update(overwrite) do
    Enum.each(overwrite, fn {key, value} ->
      set(key, value)
    end)
  end
end
