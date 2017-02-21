defmodule Tokumei.Mixfile do
  use Mix.Project

  def project do
    [app: :tokumei,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :gproc],
     mod: {Example, []}]
  end

  defp deps do
    [
      {:ace_http, "~> 0.1.3"},
      {:raxx, "~> 0.10.5"},
      {:raxx_static, "~> 0.2.0"},
      {:gproc, "0.3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
