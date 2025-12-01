# Elixir MCP SDK

An Elixir implementation of the Model Context Protocol (MCP) SDK. This SDK provides the building blocks for creating MCP servers and clients in Elixir.

## Examples

### Hello World HTTP Server

A basic HTTP server example to demonstrate Elixir web development with Bandit:

```bash
# Run the example server (recommended)
./examples/hello_world/run.sh

# Or run directly (requires --no-halt to keep running)
mix run --no-halt examples/hello_world/application.ex
```

The server will start on `http://localhost:4000` with the following endpoints:
- `GET /hello` - Returns a greeting message
- `GET /health` - Health check endpoint
- `GET /*` - Returns 404 for other routes

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_mcp_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_mcp_sdk, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/elixir_mcp_sdk>.

