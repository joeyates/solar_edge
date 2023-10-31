defmodule SolarEdge.SiteTest do
  use ExUnit.Case, async: true

  import Mox
  alias SolarEdge.{Client, Location, PowerReading, Site, Transform}

  @time_zone "Europe/Berlin"

  setup :verify_on_exit!

  @moduletag site: %Site{
    id: 1,
    client: Client.new("my_key"),
    location: %Location{time_zone: @time_zone}
  }

  def relative_date_time(offset) do
    DateTime.now!(@time_zone)
    |> DateTime.add(offset, :day)
    |> DateTime.to_date()
    |> DateTime.new!(~T[00:00:00], @time_zone)
  end

  def relative_api_date_time(offset) do
    offset
    |> relative_date_time()
    |> Transform.datetime_to_api_string()
  end

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

  describe "energy/2" do
    @describetag today: DateTime.now!(@time_zone)
      |> DateTime.to_date()
    @describetag tomorrow: DateTime.now!(@time_zone)
      |> DateTime.to_date()
      |> Date.add(1)

    setup do
      last_midnight = relative_api_date_time(0)
      day_after_midnight = relative_api_date_time(2)
      resp = %Req.Response{
        body: %{
          "energy" => %{
            "values" => [
              %{date: last_midnight, value: 42},
              %{date: day_after_midnight, value: 99}
            ]
          }
        }
      }
      stub(SolarEdge.MockClient, :get!, fn _, _, _ -> resp end)

      :ok
    end

    test "it returns readings", context do
      {_, readings} = Site.energy(context.site, start_time: context.today, end_time: context.tomorrow)

      assert %PowerReading{value: 42} = hd(readings)
    end
  end

  describe "power/2" do
    setup do
      last_midnight = relative_api_date_time(0)
      day_after_midnight = relative_api_date_time(2)
      resp = %Req.Response{
        body: %{
          "power" => %{
            "values" => [
              %{date: last_midnight, value: 42},
              %{date: day_after_midnight, value: 99}
            ]
          }
        }
      }
      stub(SolarEdge.MockClient, :get!, fn _, _, _ -> resp end)

      %{resp: resp}
    end

    test "it returns readings", context do
      {_, readings} = Site.power(context.site, start_time: relative_date_time(0), end_time: relative_date_time(1))

      assert %PowerReading{value: 42} = hd(readings)
    end

    test "it defaults to the last month", context do
      tomorrow_midnight = relative_date_time(1)
      twenty_nine_days_ago_midnight = tomorrow_midnight |> DateTime.add(-30, :day)
      start_time = twenty_nine_days_ago_midnight |> Transform.datetime_to_api_string()
      end_time = tomorrow_midnight |> Transform.datetime_to_api_string()
      expected_params = [startTime: start_time, endTime: end_time]
      expect(SolarEdge.MockClient, :get!, fn _, _, params: ^expected_params -> context.resp end)

      Site.power(context.site)
    end

    test "it skips returned readings after the end of the requested range", context do
      {_, readings} = Site.power(context.site, start_time: relative_date_time(0), end_time: relative_date_time(1))

      assert length(readings) == 1
    end

    test "it returns :ok", context do
      assert {:ok, _readings} = Site.power(context.site, start_time: relative_date_time(0), end_time: relative_date_time(1))
    end
  end
end

