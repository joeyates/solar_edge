defmodule SolarEdge.Site do
  @moduledoc """
  Site-specific information

  https://knowledge-center.solaredge.com/sites/kc/files/se_monitoring_api.pdf
  """
  alias SolarEdge.{Client, Location, PowerReading, Transform}

  @keys ~w(
    id
    installation_date
    last_update_time
    name
    notes
    peak_power
    status
    type
  )a
  @structs ~w(client location)a
  defstruct @keys ++ @structs

  def new_from_api(data, client) do
    location = Location.new_from_api(data.location)

    data
    |> Map.take(@keys)
    |> Map.put(:client, client)
    |> Map.put(:location, location)
    |> then(&struct!(__MODULE__, &1))
  end

  @doc """
  Fetch power data in 15' slices.
  Paginates if the requested time range is more than a month.

  Options:
  * start_time: Optional, defaults to start of today,
  * end_time: Optional, defaults to start_time + 1 day
  """
  def power(%__MODULE__{} = site, opts \\ []) do
    period_start_time = opts[:start_time] || previous_midnight(site)
    period_end_time = opts[:end_time] || DateTime.add(period_start_time, 30, :day)

    Stream.resource(
      fn -> period_start_time end,
      fn start_time ->
        if start_time do
          end_time = DateTime.add(start_time, 30, :day)
          results = power_page(site, start_time, end_time)
          last = hd(Enum.reverse(results))

          if DateTime.compare(last.date_time, period_end_time) == :lt do
            next_start = DateTime.add(last.date_time, 15, :minute)
            {results, next_start}
          else
            in_range =
              results
              |> Enum.filter(& DateTime.compare(&1.date_time, period_end_time) == :lt)
            {in_range, nil}
          end

        else
          {:halt, nil}
        end
      end,
      fn nil -> nil end
    )
    |> Enum.to_list()
  end

  defp power_page(%__MODULE__{} = site, start_time, end_time) do
    path = "/site/#{site.id}/power"

    params = [
      startTime: Transform.datetime_to_api_string(start_time),
      endTime: Transform.datetime_to_api_string(end_time)
    ]

    Client.get(site.client, path, params: params)
    |> get_in([Access.key!(:body), "power", "values"])
    |> Transform.symbolize()
    |> Enum.map(&PowerReading.new_from_api(&1, site))
  end

  defp today(site) do
    site.location.time_zone
    |> DateTime.now!()
    |> DateTime.to_date()
  end

  @midnight ~T[00:00:00]

  defp previous_midnight(site) do
    site
    |> today()
    |> DateTime.new!(@midnight, site.location.time_zone)
  end
end
