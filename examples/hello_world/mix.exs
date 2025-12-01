defmodule Examples.HelloWorld.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_world,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Examples.HelloWorld.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.8"},
      {:elixir_mcp_sdk, path: "../.."}
    ]
  end
end
