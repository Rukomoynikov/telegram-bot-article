defmodule StocksBotTest do
  use ExUnit.Case
  doctest StocksBot

  test "greets the world" do
    assert StocksBot.hello() == :world
  end
end
