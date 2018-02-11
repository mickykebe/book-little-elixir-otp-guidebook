defmodule Pooly.Supervisor do
  use Supervisor

  def start_link(pool_config) do
    Supervisor.start_link(__MODULE__, pool_config)
  end

  def init(pool_config) do
    children = [
      {DynamicSupervisor, name: :worker_supervisor, strategy: :one_for_one},
      %{
        id: Pooly.Server,
        start: {Pooly.Server, :start_link, [ pool_config]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
