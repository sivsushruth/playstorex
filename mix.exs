defmodule Rankz.MixProject do
  use Mix.Project

  def project do
    [
      app: :rankz,
      version: "0.1.0",
      elixir: ">= 1.7.4",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Rankz.Supervisor, []},
      extra_applications: [:logger, :hound, :cowboy, :plug, :poison, :memento]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hound, "~> 1.0"},
      {:floki, "~> 0.21.0"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.5"},
      {:poison, "~> 3.1"},
      {:plug_cowboy, "~> 1.0"},
      {:memento, "~> 0.3.1"}
    ]
  end
end
