defmodule RaxxKit.MixProject do
  use Mix.Project

  def project do
    [
      app: :raxx_kit,
      version: "0.8.4",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      docs: [extras: ["README.md"], main: "readme"],
      package: package(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Micro framework for web applications with Raxx and Ace.
    """
  end

  defp package do
    [
      maintainers: ["Peter Saxton"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/crowdhailer/raxx_kit"}
    ]
  end

  defp aliases do
    [
      "raxx.new": ["raxx.kit"]
    ]
  end
end
