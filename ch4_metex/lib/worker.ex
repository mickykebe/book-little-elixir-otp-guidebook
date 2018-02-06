defmodule Metex.Worker do
  use GenServer
  @base_url "http://api.openweathermap.org/data/2.5/weather"
  @api_key Application.get_env(:ch4_metex, :weather_api_key)

  def start_link do
    GenServer.start_link(__MODULE__, %{}, [name: :metex_worker])
  end

  def init(stats) do
    {:ok, stats}
  end

  def get_temperature(location) do
    GenServer.call(:metex_worker, {:location, location})
  end

  def get_stats do
    GenServer.call(:metex_worker, :get_stats)
  end

  def reset_stats do
    GenServer.cast(:metex_worker, :reset_stats)
  end

  def stop do
    GenServer.cast(:metex_worker, :stop)
  end

  def handle_call({:location, location}, _, stats) do
    case temperature_of(location) do
      {:ok, temp} -> 
        new_stats = update_stats(stats, location)
        {:reply, "#{temp}°C", new_stats}
      _ -> {:reply, :error, stats}
    end
  end

  def handle_call(:get_stats, _, stats) do
    {:reply, stats, stats}
  end

  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end

  def handle_info(msg, stats) do
    IO.puts "received #{inspect msg}"
    {:noreply, stats}
  end

  def terminate(reason, stats) do
    IO.puts "server terminated because of #{inspect reason}"
    inspect stats
    :ok
  end

  def temperature_of(location) do
    url_for(location)
      |> HTTPoison.get
      |> parse_response
  end

  defp url_for(location) do
    location = URI.encode(location)
    "#{@base_url}?q=#{location}&appid=#{@api_key}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
      |> JSON.decode!
      |> compute_temprature
  end

  defp parse_response(response) do
    IO.inspect(response)
    :error
  end

  defp compute_temprature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15)
        |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true -> Map.update!(old_stats, location, &(&1 + 1))
      false -> Map.put_new(old_stats, location, 1)
    end
  end
end