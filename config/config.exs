import Config

config :elixir,
  time_zone_database: TimeZoneInfo.TimeZoneDatabase

case config_env() do
  :test ->
    config :solar_edge, req: MockReq
    config :solar_edge, solar_edge_client: SolarEdge.MockClient
    config :logger, backends: []

  _ ->
    nil
end
