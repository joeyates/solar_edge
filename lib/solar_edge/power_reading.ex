defmodule SolarEdge.PowerReading do
  defstruct ~w(date_time site value)a

  def new_from_api(data, site) do
    naive = NaiveDateTime.from_iso8601!(data.date)

    date_time =
      case DateTime.from_naive(naive, site.location.time_zone) do
        {:ok, date_time} ->
          date_time

        other ->
          if elem(other, 0) != :ambiguous do
            raise "Unexpected result from DateTime.from_naive/2: #{inspect(other)}"
          end

          elem(other, 1)
      end

    %{
      date_time: date_time,
      site: site,
      value: data.value
    }
    |> then(&struct!(__MODULE__, &1))
  end

  def to_row(%__MODULE__{} = reading) do
    [DateTime.to_iso8601(reading.date_time), reading.value]
  end
end
