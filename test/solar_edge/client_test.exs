defmodule SolarEdge.ClientTest do
  use ExUnit.Case, async: true
  import Mox

  setup do
    resp = %Req.Response{}
    stub(MockReq, :get!, fn _ -> resp end)

    client = SolarEdge.Client.new("my_key")
    %{client: client}
  end

  describe "get/3" do
    test "it returns the response", %{client: client} do
      {_, resp} = SolarEdge.Client.get(client, "foo")

      assert %Req.Response{} = resp
    end
  end
end
