defmodule Tokumei.Mixfile do
  use Mix.Project

  def project do
    [app: :Tokumei,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger],
     mod: {Example, []}]
  end

  defp deps do
    [
      {:ace_http, "~> 0.1.3"},
      {:raxx, "~> 0.10.3"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
