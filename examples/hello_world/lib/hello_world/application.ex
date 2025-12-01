defmodule Examples.HelloWorld.Application do
  @moduledoc """
  OTP Application for the Hello World HTTP server example.

  This demonstrates how to start a Bandit server as part of an Elixir application.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit, plug: Examples.HelloWorld.Server}
    ]

    opts = [strategy: :one_for_one, name: Examples.HelloWorld.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
