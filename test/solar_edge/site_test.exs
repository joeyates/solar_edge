defmodule SolarEdge.SiteTest do
  use ExUnit.Case, async: true

  import Mox
  alias SolarEdge.{Client, Location, PowerReading, Site}

  @time_zone "Europe/Berlin"

  setup :verify_on_exit!

  describe ".new_from_api/2" do
    @describetag client: Client.new("my_key")
    @describetag data: %{id: 42, location: %{address: "32 High Street"}}

    test "it accepts attributes", %{client: client, data: data} do
      {_, site} = Site.new_from_api(data, client)

      assert %Site{id: 42} = site
    end

    test "it returns the location", %{client: client, data: data} do
      {_, site} = Site.new_from_api(data, client)

      assert %Location{address: "32 High Street"} = site.location
    end

    test "it returns :ok", %{client: client, data: data} do
      assert {:ok, _site} = Site.new_from_api(data, client)
    end
  end

  describe "power/2" do
    @describetag site: %Site{
      id: 1,
      client: Client.new("my_key"),
      location: %Location{time_zone: @time_zone}
    }
    @describetag today: DateTime.now!(@time_zone)
      |> DateTime.to_date()
      |> DateTime.new!(~T[00:00:00], @time_zone)
    @describetag tomorrow: DateTime.now!(@time_zone)
      |> DateTime.add(1, :day)
      |> DateTime.to_date()
      |> DateTime.new!(~T[00:00:00], @time_zone)
    @describetag day_after: DateTime.now!(@time_zone)
      |> DateTime.add(2, :day)
      |> DateTime.to_date()
      |> DateTime.new!(~T[00:00:00], @time_zone)

    setup context do
      today = context.today |> SolarEdge.Transform.datetime_to_api_string()
      day_after = context.day_after |> SolarEdge.Transform.datetime_to_api_string()
      resp = %Req.Response{
        body: %{
          "power" => %{
            "values" => [
              %{date: today, value: 42},
              %{date: day_after, value: 99}
            ]
          }
        }
      }
      stub(SolarEdge.MockClient, :get!, fn _, _, _ -> resp end)

      %{resp: resp}
    end

    test "it returns readings", context do
      {_, readings} = Site.power(context.site, start_time: context.today, end_time: context.tomorrow)

      assert %PowerReading{value: 42} = hd(readings)
    end

    test "it defaults to the last month", context do
      month_ago =
        context.tomorrow
        |> DateTime.add(-30, :day)
        |> SolarEdge.Transform.datetime_to_api_string()
      tomorrow = context.tomorrow |> SolarEdge.Transform.datetime_to_api_string()
      expected_params = [startTime: month_ago, endTime: tomorrow]
      expect(SolarEdge.MockClient, :get!, fn _, _, params: ^expected_params -> context.resp end)

      Site.power(context.site)
    end

    test "it skips returned readings after the end of the requested range", context do
      {_, readings} = Site.power(context.site, start_time: context.today, end_time: context.tomorrow)

      assert length(readings) == 1
    end

    test "it returns :ok", context do
      assert {:ok, _readings} = Site.power(context.site, start_time: context.today, end_time: context.tomorrow)
    end
  end
end

