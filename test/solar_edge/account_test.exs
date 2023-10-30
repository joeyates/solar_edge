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
    :ok
  end

  @moduletag client: SolarEdge.Client.new("my_key")

  describe "site_list/1" do
    test "it returns the sites", %{client: client} do
      {:ok, sites} = SolarEdge.Account.site_list(client)

      assert %SolarEdge.Site{id: 42} = hd(sites)
    end

    test "it returns :ok", %{client: client} do
      assert {:ok, _} = SolarEdge.Account.site_list(client)
    end
  end

  describe "site_list!/1" do
    test "it returns the sites", %{client: client} do
      sites = SolarEdge.Account.site_list!(client)

      assert %SolarEdge.Site{id: 42} = hd(sites)
    end
  end
end

