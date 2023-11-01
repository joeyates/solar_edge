defmodule SolarEdge.Site do
  @moduledoc """
  Site-specific information

  https://knowledge-center.solaredge.com/sites/kc/files/se_monitoring_api.pdf
  """
  alias SolarEdge.{Location, PowerReading, Transform}

  @client Application.compile_env(:solar_edge, :solar_edge_client, SolarEdge.Client)

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
    location = Location.new_from_api!(data.location)

    data
    |> Map.take(@keys)
    |> Map.put(:client, client)
    |> Map.put(:location, location)
    |> then(&struct!(__MODULE__, &1))
    |> then(& {:ok, &1})
  end

  def new_from_api!(data, client) do
    {:ok, site} = new_from_api(data, client)
    site
  end

  @doc """
  Fetch the site's energy production.
  """
  def energy(%__MODULE__{} = site, opts \\ []) do
    period_end_date = opts[:end_date] || today(site)
    period_start_date = opts[:start_date] || Date.add(period_end_date, -30)

    Stream.resource(
      fn -> period_start_date end,
      fn start_date ->
        if start_date do
          end_date = Date.add(start_date, 30)
          results = energy_page(site, start_date, end_date)
          last = hd(Enum.reverse(results))

          if Date.compare(last.date_time, period_end_date) == :lt do
            next_start = Date.add(last.date_time, 1)

            {results, next_start}
          else
            in_range =
              results
              |> Enum.filter(& Date.compare(&1.date_time, period_end_date) != :gt)
            {in_range, nil}
          end

        else
          {:halt, nil}
        end
      end,
      fn _ -> nil end
    )
    |> Enum.to_list()
    |> then(& {:ok, &1})
  end

  defp energy_page(site, start_date, end_date) do
    path = "/site/#{site.id}/energy"

    params = [
      startDate: Date.to_iso8601(start_date),
      endDate: Date.to_iso8601(end_date)
    ]

    energy =
      @client.get!(site.client, path, params: params)
      |> get_in([Access.key!(:body), "energy"])

    unit = energy["unit"]

    energy["values"]
    |> Transform.symbolize()
    |> Enum.map(&PowerReading.new_from_api!(&1, unit, site))
  end

  @doc """
  Fetch power data in 15' slices.
  Paginates if the requested time range is more than a month.

  Options:
  * end_time: Optional, defaults to midnight tonight,
  * start_time: Optional, defaults to 30 days before end_time.
  """
  def power(%__MODULE__{} = site, opts \\ []) do
    period_end_time = opts[:end_time] || next_midnight(site)
    period_start_time = opts[:start_time] ||
      period_end_time |> DateTime.add(-30, :day)

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
      fn _ -> nil end
    )
    |> Enum.to_list()
    |> then(& {:ok, &1})
  end

  def power!(site, opts \\ []) do
    {:ok, readings} = power(site, opts)
    readings
  end

  defp power_page(%__MODULE__{} = site, start_time, end_time) do
    path = "/site/#{site.id}/power"

    params = [
      startTime: Transform.datetime_to_api_string(start_time),
      endTime: Transform.datetime_to_api_string(end_time)
    ]

    power =
      @client.get!(site.client, path, params: params)
      |> get_in([Access.key!(:body), "power"])

    unit = power["unit"]

    power["values"]
    |> Transform.symbolize()
    |> Enum.map(&PowerReading.new_from_api!(&1, unit, site))
  end

  defp today(site) do
    site.location.time_zone
    |> DateTime.now!()
    |> DateTime.to_date()
  end

  @midnight ~T[00:00:00]

  defp next_midnight(site) do
    site
    |> today()
    |> Date.add(1)
    |> DateTime.new!(@midnight, site.location.time_zone)
  end
end
