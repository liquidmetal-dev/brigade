defmodule BrigadeTest do
  use ExUnit.Case
  doctest Brigade

  test "greets the world" do
    assert Brigade.hello() == :world
  end
end
