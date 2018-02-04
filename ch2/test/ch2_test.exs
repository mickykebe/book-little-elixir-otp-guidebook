defmodule Ch2Test do
  use ExUnit.Case
  doctest Ch2

  test "greets the world" do
    assert Ch2.hello() == :world
  end
end
