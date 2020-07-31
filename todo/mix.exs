defmodule Todo.MixProject do
  use Mix.Project

  def project do
    [
      app: :todo,
      version: "0.2.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [release: :prod]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Todo.Application, []}
    ]
  end

  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:cowboy, "~> 2.8"},
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.3"},
      {:distillery, "~> 2.1"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
