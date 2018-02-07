defmodule Ring do
  def create_processes(n) do
    1..n
      |> Enum.map(fn _ -> spawn(fn -> loop() end) end)
  end

  def loop do
    receive do
      {:link, link_to} when is_pid(link_to) ->
        Process.link(link_to)
        loop()
      :trap_exit ->
        Process.flag(:trap_exit, true)
        loop()
      :crash ->
        raise("crash")
      {:EXIT, pid, reason} ->
        IO.puts "#{inspect self()} received {:EXIT, #{inspect pid}, #{reason}}"
        loop()
    end
  end

  def link_processes(procs) do
    link_processes(procs, [])
  end

  def link_processes([proc1 | [proc2 | rest]], linked_processes) do
    send(proc1, {:link, proc2})
    link_processes([proc2 | rest], linked_processes ++ [proc1])
  end

  def link_processes([proc | []], [proc1 | _rest]) do
    send(proc, {:link, proc1})
    :ok
  end
end
