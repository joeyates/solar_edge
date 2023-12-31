defmodule SolarEdge.Location do
  @keys ~w(
    address
    address2
    city
    country
    country_code
    time_zone
    zip
  )a
  defstruct @keys

  def new_from_api(data) do
    data
    |> Map.take(@keys)
    |> then(&struct!(__MODULE__, &1))
    |> then(& {:ok, &1})
  end

  def new_from_api!(data) do
    {:ok, location} = new_from_api(data)
    location
  end
end
