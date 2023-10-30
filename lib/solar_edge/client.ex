defmodule SolarEdge.Client do
  require Logger

  defstruct ~w(api_key)a

  @type t :: %__MODULE__{
    api_key: String.t()
  }

  @base_url "https://monitoringapi.solaredge.com"

  @req Application.compile_env(:solar_edge, :req, Req)

  def new(api_key) do
    %__MODULE__{api_key: api_key}
  end

  @callback get(SolarEdge.Client.t(), String.t(), Keyword.t()) :: {:ok, Req.Response.t()}
  @callback get(SolarEdge.Client.t(), String.t()) :: {:ok, Req.Response.t()}
  def get(%__MODULE__{} = client, path, opts \\ []) do
    params = opts[:params] || []
    url = Path.join(@base_url, path)

    params = params(client, params)

    Req.new(url: url, headers: headers(), params: params)
    |> @req.get!()
    |> tap(&Logger.debug("GET #{url}: #{inspect(&1)}"))
    |> then(& {:ok, &1})
  end

  @callback get!(SolarEdge.Client.t(), String.t(), Keyword.t()) :: Req.Response.t()
  @callback get!(SolarEdge.Client.t(), String.t()) :: Req.Response.t()
  def get!(client, path, opts \\ []) do
    {:ok, %Req.Response{status: 200} = response} = get(client, path, opts)
    response
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
