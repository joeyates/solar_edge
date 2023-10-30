defmodule SolarEdge.Account do
  @moduledoc """
  Access account-wide (not site-specific) information

  https://knowledge-center.solaredge.com/sites/kc/files/se_monitoring_api.pdf
  """
  alias SolarEdge.{Client, Site, Transform}

  @client Application.compile_env(:solar_edge, :client, SolarEdge.Client)

  @doc ~S"""
  Fetch a list of sites accessible by the supplied client API key
  """
  @callback site_list(SolarEdge.Client.t()) :: {:ok, [SolarEdge.Site.t()]}
  def site_list(%Client{} = client) do
    path = "/sites/list"

    @client.get!(client, path)
    |> get_in([Access.key!(:body), "sites", "site"])
    |> Transform.symbolize()
    |> Enum.map(&Site.new_from_api!(&1, client))
    |> then(& {:ok, &1})
  end

  def site_list!(client) do
    {:ok, list} = site_list(client)
    list
  end
end
