defmodule SolarEdge.AccountTest do
  use ExUnit.Case, async: true
  import Mox

  setup do
    location = %{}
    resp = %Req.Response{
      body: %{
        "sites" => %{
          "site" => [%{id: 42, location: location}]
        }
      }
    }
    stub(SolarEdge.MockClient, :get!, fn _, _ -> resp end)

    client = SolarEdge.Client.new("my_key")
    %{client: client}
  end

  test "it returns the sites", %{client: client} do
    {:ok, sites} = SolarEdge.Account.site_list(client)

    assert %SolarEdge.Site{} = hd(sites)
  end
end

