defmodule Sitemaps.DSL do
  @moduledoc """
  The DSL is the implementation of the most important part
  of this project, it's going to help you to define the
  pages to be included in the sitemap.

  As an example, you can see in the README.md file this example:

  ```elixir
  defmodule MyApp.Sitemaps do
    use Sitemaps

    def generate do
      create do
        # list each URL that should be included
        add "path1", priority: 0.5, changefreq: "hourly", expires: nil, mobile: true
        # ...
      end

      # notify search engines (currently Google and Bing) of the updated sitemap
      ping()
    end
  end
  ```

  Adding `use Sitemaps` in the beginning of the module you choose for
  setting your sitemap it will add some stuff that will let you use
  the `create/1` macros and other functions like `ping/0`.
  """

  @doc false
  defmacro __using__(opts) do
    quote do
      @__use_resource__ unquote(opts)

      import Sitemaps.DSL
      import Sitemaps.Generator
    end
  end

  @doc """
  Let you define the sitemap. It's creating the environment where you
  could use `add/2` as many times as you need. In this case you can
  specify actions before starting with the block. These options are
  the same as you can see in the `Sitemaps.Config` module.
  """
  defmacro create(options, contents) do
    quote do
      Sitemaps.Config.update(@__use_resource__)
      Sitemaps.Config.update(unquote(options))
      create(unquote(contents ++ [use: false]))
    end
  end

  @doc """
  Same as `create/2` but without specifying options.
  """
  defmacro create(contents) do
    case contents do
      [do: block] ->
        quote do
          Sitemaps.Config.update(@__use_resource__)
          unquote(block)
          fin()
        end

      [do: block, use: false] ->
        quote do
          unquote(block)
          fin()
        end
    end
  end
end
