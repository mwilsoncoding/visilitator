defmodule ElixirDevTest do
  use ExUnit.Case
  doctest ElixirDev

  test "greets the world" do
    assert ElixirDev.hello() == :world
  end
end
