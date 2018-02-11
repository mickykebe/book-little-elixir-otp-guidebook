defmodule Pooly.Server do
  use GenServer

  defmodule State do
    defstruct size: nil, child_spec: nil, workers: nil, monitors: nil
  end

  def start_link(pool_config) do
    GenServer.start_link(__MODULE__, pool_config, name: __MODULE__)
  end

  def init(pool_config) do
    monitors = :ets.new(:monitors, [:private])
    init(pool_config, %State{monitors: monitors})
  end

  def init([{:child_spec, child_spec} | rest], state) do
    init(rest, %State{state | child_spec: child_spec})
  end

  def init([{:size, size} | rest], state) do
    init(rest, %State{state | size: size})
  end

  def init([_ | rest], state) do
    init(rest, state)
  end

  def init([], state) do
    send(self(), :start_workers)
    {:ok, state}
  end

  def checkout do
    GenServer.call(__MODULE__, :checkout)
  end

  def checkin(worker_pid) do
    GenServer.cast(__MODULE__, {:checkin, worker_pid})
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  def handle_call(:checkout, {from_pid, _ref}, %{workers: workers, monitors: monitors} = state) do
    case workers do
      [worker | rest] ->
        ref = Process.monitor(from_pid)
        true = :ets.insert(monitors, {worker, ref})
        {:reply, worker, %{state | workers: rest}}

      [] ->
        {:reply, :noproc, state}
    end
  end

  def handle_call(:status, _from, %{workers: workers, monitors: monitors} = state) do
    {:reply, {length(workers), :ets.info(monitors, :size)}, state}
  end

  def handle_cast({:checkin, worker}, %{workers: workers, monitors: monitors} = state) do
    case :ets.lookup(monitors, worker) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        {:noreply, %{state | workers: [pid | workers]}}

      [] ->
        {:noreply, state}
    end
  end

  def handle_info(
        :start_workers,
        state = %State{child_spec: child_spec, size: size}
      ) do
    # {:ok, worker_sup} =
    #   Supervisor.start_child(
    #     sup,
    #     {DynamicSupervisor, strategy: :one_for_one}
    #   )

    workers = prepopulate(size, :worker_supervisor, child_spec)
    {:noreply, %State{state | workers: workers}}
  end

  defp prepopulate(size, sup, spec) do
    prepopulate(size, sup, spec, [])
  end

  defp prepopulate(size, _sup, _spec, workers) when size < 1 do
    workers
  end

  defp prepopulate(size, sup, spec, workers) do
    prepopulate(size - 1, sup, spec, [new_worker(sup, spec) | workers])
  end

  defp new_worker(sup, spec) do
    {:ok, worker} = DynamicSupervisor.start_child(sup, spec)
    worker
  end
end
