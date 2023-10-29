defmodule SolarEdge.MixProject do
  use Mix.Project

  def project do
    [
      app: :solar_edge,
      version: "0.0.1",
      elixir: "~> 1.14",
      description: "Access the SolarEdge monitoring API",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: Mix.env() != :test
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.4.5"},
      {:time_zone_info, "~> 0.6.5"}
    ]
  end
end
