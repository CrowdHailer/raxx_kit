defmodule Tokumei.Mixfile do
  use Mix.Project

  def project do
    [app: :tokumei,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     docs: [extras: ["README.md"], main: "readme"],
     package: package()]
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

  defp description do
    """
    Tiny but MIGHTY Elixir webframework.
    """
  end

  defp package do
    [# These are the default files included in the package
     files: ["lib", "mix.exs", "README*", "LICENSE*", ],
     maintainers: ["Peter Saxton"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/CrowdHailer/Tokumei/tree/master/app"}]
end
end
