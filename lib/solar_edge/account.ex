defmodule SolarEdge.Account do
  @moduledoc """
  Access account-wide (not site-specific) information

  https://knowledge-center.solaredge.com/sites/kc/files/se_monitoring_api.pdf
  """
  alias SolarEdge.{Client, Site, Transform}

  def site_list(%Client{} = client) do
    path = "/sites/list"

    Client.get!(client, path)
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
