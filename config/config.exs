import Config

config :elixir,
  time_zone_database: TimeZoneInfo.TimeZoneDatabase

case config_env() do
  :test ->
    config :solar_edge, client: SolarEdge.MockClient

  _ ->
    nil
end
