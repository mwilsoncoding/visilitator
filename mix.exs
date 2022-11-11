defmodule Visilitator.MixProject do
  use Mix.Project

  def project do
    [
      app: :visilitator,
      version: "0.1.0",
      elixir: System.fetch_env!("ELIXIR_VSN"),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Visilitator.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.9"},
      {:postgrex, "~> 0.16.5"}
    ]
  end
end
