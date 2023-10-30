defmodule SolarEdge.Transform do
  @moduledoc """
  Data transformation conveniences
  """

  @camel_case_match ~r/
    ^        # From the start of the string
    [a-z]+   # at least one lowercase character
    (
      [A-Z]  # an uppercase character
      [a-z]+ # at least one lowercase character
    )*       # 0, or more, times
    $        # to the end of the string
  /x

  @doc """
  Transform API data into a structure where Map keys
  are snake-cased and atomized

  iex> SolarEdge.Client.symbolize("a")
  :a

  iex> SolarEdge.Client.symbolize("aBc")
  :a_bc

  Keys are transformed to snake only when the transformation is reversible

  iex> SolarEdge.Client.symbolize("aBC")
  :aBC

  iex> SolarEdge.Client.symbolize({1, "a"})
  {1, "a"}

  iex> SolarEdge.Client.symbolize(%{"a" => 1})
  %{a: 1}

  iex> SolarEdge.Client.symbolize(["a"])
  ["a"]

  iex> SolarEdge.Client.symbolize(%{"a" => [%{"b" => "c"}]})
  %{a: [%{b: "c"}]}
  """
  def symbolize(data) when is_map(data) do
    data
    |> Enum.map(fn
      {k, v} when is_binary(v) ->
        {symbolize(k), v}

      {k, v} ->
        {symbolize(k), symbolize(v)}
    end)
    |> Enum.into(%{})
  end

  def symbolize(data) when is_list(data) do
    data
    |> Enum.map(fn
      v when is_binary(v) ->
        v

      v ->
        symbolize(v)
    end)
  end

  def symbolize(data) when is_binary(data) do
    if String.match?(data, @camel_case_match) do
      Macro.underscore(data)
    else
      data
    end
    |> String.to_atom()
  end

  def symbolize(data), do: data

  @doc """
  Convert a DateTime to a string, **without** timezone information
  """
  def datetime_to_api_string(%DateTime{} = dt) do
    dt
    |> DateTime.to_string()
    |> String.replace(~r/^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*/, "\\1")
  end
end
