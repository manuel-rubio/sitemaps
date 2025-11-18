defmodule Sitemap.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sitemap,
      name: "Sitemap",
      version: "1.1.0",
      elixir: ">= 1.3.0",
      description: "Generating sitemap.xml",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      source_url: "https://github.com/manuel-rubio/sitemap"
    ]
  end

  def application do
    [
      extra_applications: [:inets],
      mod: {Sitemap, []}
    ]
  end

  defp deps do
    [
      {:xml_builder, ">= 0.0.0"},
      {:ecto, ">= 1.1.0", only: :test},
      {:sweet_xml, ">= 0.0.0", only: :test},
      {:earmark, ">= 0.0.0", only: :dev},

      # only for dev
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:doctor, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.14", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Tatsuo Ikeda / ikeikeikeike", "Manuel Rubio / manuel-rubio"],
      licenses: ["MIT"],
      links: %{"github" => "https://github.com/manuel-rubio/sitemap"}
    ]
  end
end
