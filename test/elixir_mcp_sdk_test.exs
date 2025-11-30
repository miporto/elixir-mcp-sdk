defmodule ElixirMcpSdkTest do
  use ExUnit.Case
  doctest ElixirMcpSdk

  test "greets the world" do
    assert ElixirMcpSdk.hello() == :world
  end
end
