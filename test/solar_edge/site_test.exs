defmodule SolarEdge.SiteTest do
  use ExUnit.Case, async: true
  import Mox

  setup do
    client = SolarEdge.Client.new("my_key")
    data = %{id: 42, location: %{address: "32 High Street"}}
    %{client: client, data: data}
  end

  describe ".new_from_api/2" do
    test "it accepts attributes", %{client: client, data: data} do
      {_, site} = SolarEdge.Site.new_from_api(data, client)

      assert %SolarEdge.Site{id: 42} = site
    end

    test "it returns the location", %{client: client, data: data} do
      {_, site} = SolarEdge.Site.new_from_api(data, client)

      assert %SolarEdge.Location{address: "32 High Street"} = site.location
    end

    test "it returns :ok", %{client: client, data: data} do
      assert {:ok, _site} = SolarEdge.Site.new_from_api(data, client)
    end
  end
end

