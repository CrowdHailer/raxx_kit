defmodule Tokumei.Router.Mixfile do
  use Mix.Project

  def project do
    [app: :tokumei_router,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: "Tiny but might Elixir web framework",
     docs: [extras: ["README.md"], main: "readme"],
     package: package()
   ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:raxx, "~> 0.8.2"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
     maintainers: ["Peter Saxton"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/crowdhailer/raxx"}]
  end
end
