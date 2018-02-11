defmodule WorkerSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    IO.puts("Starting worker supervisor")
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end