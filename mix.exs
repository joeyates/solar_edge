defmodule SolarEdge.MixProject do
  use Mix.Project

  def project do
    [
      app: :solar_edge,
      version: "0.0.1",
      elixir: "~> 1.14",
      description: "Access the SolarEdge monitoring API",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: Mix.env() != :test,
      test_coverage: [tool: ExCoveralls],
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.json": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: extra_applications(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp extra_applications(:test), do: [:logger, :mox]
  defp extra_applications(_env), do: [:logger]

  defp deps do
    [
      {:excoveralls, ">= 0.0.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mox, ">= 0.0.0", only: :test, runtime: false},
      {:req, "~> 0.4.5"},
      {:time_zone_info, "~> 0.6.5"}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/joeyates/solar_edge"
      },
      maintainers: ["Joe Yates"]
    }
  end
end
