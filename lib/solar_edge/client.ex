defmodule SolarEdge.Client do
  require Logger

  defstruct ~w(api_key)a

  @base_url "https://monitoringapi.solaredge.com"

  def new(api_key) do
    %__MODULE__{api_key: api_key}
  end

  def get(%__MODULE__{} = client, path, opts \\ []) do
    params = opts[:params] || []
    url = Path.join(@base_url, path)

    params = params(client, params)

    Req.new(url: url, headers: headers(), params: params)
    |> Req.get!()
    |> tap(&Logger.debug("GET #{url}: #{inspect(&1)}"))
  end

  defp headers do
    [
      {"Accept", "application/json"}
    ]
  end

  defp params(%__MODULE__{} = client, params) do
    [{:api_key, client.api_key} | params]
  end
end
