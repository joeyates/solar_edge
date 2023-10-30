defmodule SolarEdge.PowerReading do
  defstruct ~w(date_time site value)a

  @doc ~S"""
  Converts a Map of API power data to a PowerReading

      iex> location = %SolarEdge.Location{time_zone: "Europe/Berlin"}
      iex> site = %SolarEdge.Site{location: location}
      iex> {:ok, reading} = SolarEdge.PowerReading.new_from_api(%{date: "2023-10-18 00:15:00", value: 3}, site)
      iex> reading.date_time
      #DateTime<2023-10-18 00:15:00+02:00 CEST Europe/Berlin>
      iex> reading.value
      3
      # Now with an ambiguous time
      iex> {:ok, reading} = SolarEdge.PowerReading.new_from_api(%{date: "2023-10-29 02:00:00", value: 3}, site)
      iex> reading.date_time
      #DateTime<2023-10-29 02:00:00+02:00 CEST Europe/Berlin>
  """
  def new_from_api(data, site) do
    naive = NaiveDateTime.from_iso8601!(data.date)

    date_time =
      case DateTime.from_naive(naive, site.location.time_zone) do
        {:ok, date_time} ->
          date_time

        other ->
          elem(other, 1)
      end

    %{
      date_time: date_time,
      site: site,
      value: data.value
    }
    |> then(&struct!(__MODULE__, &1))
    |> then(& {:ok, &1})
  end

  def new_from_api!(data, site) do
    {:ok, reading} = new_from_api(data, site)
    reading
  end

  def to_row(%__MODULE__{} = reading) do
    [DateTime.to_iso8601(reading.date_time), reading.value]
  end
end
