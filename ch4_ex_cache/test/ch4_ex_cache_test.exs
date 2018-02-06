defmodule Ch4ExCacheTest do
  use ExUnit.Case
  doctest Ch4ExCache

  test "greets the world" do
    assert Ch4ExCache.hello() == :world
  end
end
