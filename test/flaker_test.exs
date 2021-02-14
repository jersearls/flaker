defmodule FlakerTest do
  use ExUnit.Case
  doctest Flaker

  test "greets the world" do
    assert Flaker.hello() == :world
  end
end
