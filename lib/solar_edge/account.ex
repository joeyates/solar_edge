defmodule SolarEdge.Account do
  @moduledoc """
  Access account-wide (not site-specific) information

  https://knowledge-center.solaredge.com/sites/kc/files/se_monitoring_api.pdf
  """
  alias SolarEdge.Client

  def site_list(%Client{} = client) do
    path = "/sites/list"

    Client.get(client, path)
    |> get_in([Access.key!(:body), "sites", "site"])
    |> Client.symbolize()
    |> Enum.map(&SolarEdge.Site.new_from_api(&1, client))
  end
end
