defmodule RaxxKit.MixProject do
  use Mix.Project

  def project do
    [
      app: :raxx_kit,
      version: "0.4.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end
