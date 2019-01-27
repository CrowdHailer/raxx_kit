defmodule Formular.Mixfile do
  use Mix.Project

  def project do
    [
      app: :formular,
      version: "0.1.0",
      elixir: "~> 1.7.1",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {Formular.Application, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ace, "~> 0.18.0"},
      # temporary while working on middleware branches
      {:raxx, github: "crowdhailer/raxx", branch: "extract-logger", override: true},
      {:raxx_logger,
       github: "crowdhailer/raxx_kit",
       branch: "runtime-raxx-logger",
       sparse: "extensions/raxx_logger"},
      {:raxx_static,
       github: "crowdhailer/raxx_kit",
       branch: "runtime-static-middleware",
       sparse: "extensions/raxx_static"},
      {:ecto, "~> 3.0"},
      {:ok, "~> 2.0"},
      {:exsync, "~> 0.2.3", only: :dev}
    ]
  end

  defp aliases() do
    []
  end
end
