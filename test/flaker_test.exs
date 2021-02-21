defmodule FlakerTest do
  use ExUnit.Case

  require Integer

  test "passing test" do
    assert true
  end

  test "flakey test" do
    random_number = Enum.random(0..100)

    assert Integer.is_even(random_number)
  end
end
