# Elixir MCP SDK Development Guide

## Build/Test Commands
- **Build**: `mix compile`
- **Test all**: `mix test`
- **Test single file**: `mix test test/file_test.exs`
- **Test single test**: `mix test test/file_test.exs:5` (line number)
- **Format code**: `mix format`
- **Check formatting**: `mix format --check-formatted`

## Code Style Guidelines

### General Elixir Best Practices
- Follow Elixir naming conventions: modules in PascalCase, functions/variables in snake_case
- Use `@moduledoc` and `@doc` for all public modules and functions
- Write doctests for public functions
- Prefer pattern matching over conditionals
- Use pipe operator `|>` for data transformations
- Handle errors with `{:ok, result}` / `{:error, reason}` tuples

### Imports and Modules
- Group imports logically, separate stdlib from external deps
- Use `alias` for readability, avoid deep nesting
- Import only what's needed, prefer qualified calls for clarity

### Types and Specifications
- Use `@type`, `@spec` for public APIs
- Define custom types in modules for complex data structures
- Use Dialyzer for static type checking: `mix dialyzer`

### Error Handling
- Use `with` for complex error handling flows
- Prefer `case` over `if/else` for multiple conditions
- Return descriptive error tuples, avoid exceptions for control flow

### Testing
- Write tests for all public functions
- Use descriptive test names
- Test both success and error cases
- Use `assert` for simple checks, `assert_receive` for async tests

### Learning Focus
This project builds an MCP SDK while learning Elixir. Prioritize:
- Understanding functional programming concepts
- Exploring Elixir's concurrency model with processes
- Learning OTP patterns and behaviors
- Following community best practices from Elixir documentation

### MCP Development
- **Protocol Version**: This SDK implements MCP protocol version `2025-11-25`
- Check https://modelcontextprotocol.io/llms.txt for accessing all MCP related documentation when building the MCP SDK
- Specification: https://modelcontextprotocol.io/specification/2025-11-25
- Changelog: https://modelcontextprotocol.io/specification/2025-11-25/changelog
- Refer to `docs/DEVELOPMENT_PLAN.md` for the comprehensive development roadmap and implementation phases</content>
<parameter name="filePath">AGENTS.md