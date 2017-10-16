defmodule EctoFunctionTest do
  use ExUnit.Case
  doctest EctoFunction

  test "greets the world" do
    assert EctoFunction.hello() == :world
  end
end
