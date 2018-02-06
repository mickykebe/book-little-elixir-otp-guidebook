defmodule Ping do
  def loop do
    receive do
      {pid, :ping} ->
        IO.puts(:ping)
        send(pid, {self(), :pong})
    end
    loop()
  end
end

defmodule Pong do
  def loop do
    receive do
      {pid, :pong} ->
        IO.puts(:pong)
        send(pid, {self(), :ping})
    end
    loop()
  end
end

defmodule PingPong do
  def start do
    ping_pid = spawn(Ping, :loop, [])
    pong_pid = spawn(Pong, :loop, [])
    send(ping_pid, {pong_pid, :ping})
  end
end