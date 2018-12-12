defmodule CFEnv.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cf_env,
      version: "1.0.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "CFEnv",
      source_url: "https://github.com/matthewoden/CFEnv",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:poison, "~> 3.0", optional: true},
      # for post-processors, vault, etc
      {:jason, "~> 1.1", optional: true},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [main: "CFEnv", extras: ["README.md"]]
  end

  def description do
    "A helper application for fetching and parsing CloudFoundry service bindings, and application information."
  end

  defp package() do
    [
      maintainers: ["Matthew Potter"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/matthewoden/CFEnv"}
    ]
  end
end
