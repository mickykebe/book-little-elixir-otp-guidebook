defmodule Exercises do
  #1
  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)

  #3
  def transform(list) do
    list
      |> List.flatten
      |> Enum.reverse
      |> Enum.map(&(&1*&1))
  end

  #4
  #:crypto.md5
end