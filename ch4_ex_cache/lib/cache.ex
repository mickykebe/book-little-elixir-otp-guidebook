defmodule Cache do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, Map.new(), [name: :cache])
  end

  def init(state) do
    {:ok, state}
  end

  def write(key, val) do
    GenServer.cast(:cache, {:write, key, val})
  end

  def read(key) do
    GenServer.call(:cache, {:read, key})
  end

  def delete(key) do
    GenServer.cast(:cache, {:delete, key})
  end

  def clear do
    GenServer.cast(:cache, :clear)
  end

  def exist?(key) do
    GenServer.call(:cache, {:exist?, key})
  end

  def handle_cast({:write, key, val}, state) do
    {:noreply, Map.put(state, key, val)}
  end

  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  def handle_cast(:clear, _state) do
    {:noreply, Map.new}
  end

  def handle_call({:read, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:exist?, key}, _from, state) do
    {:reply, Map.has_key?(state, key), state}
  end
end
