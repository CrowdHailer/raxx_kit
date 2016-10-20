defmodule Baobab.Mixfile do
  use Mix.Project

  def project do
    [app: :baobab,
     version: "0.1.0",
     elixir: "~> 1.1-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug],
     mod: {Baobab, []}]
  end

  defp deps do
    [
      {:cowboy, "1.0.4"},
      {:plug, "~> 1.1.4"},
      {:distillery, "~> 0.10"}
    ]
  end
end
