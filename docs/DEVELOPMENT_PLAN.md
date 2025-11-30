# Elixir MCP SDK Development Plan

## Overview

This document outlines the comprehensive plan for building an Elixir SDK for the Model Context Protocol (MCP). The SDK will provide a complete implementation of the MCP protocol while maintaining flexibility for users to choose their preferred HTTP server implementations.

## Core Principles

- **SDK Scope**: Provide MCP protocol implementation, transport abstractions, and framework utilities - NOT runtime servers
- **Dependencies**: Use Elixir stdlib JSON (1.18+), no external JSON libraries
- **Architecture**: Transport abstractions allow users to choose HTTP servers (Bandit, Cowboy, etc.)
- **Structure**: SDK library in `lib/`, examples in `examples/` for testing and documentation

## Directory Structure

```
elixir-mcp-sdk/
├── lib/
│   ├── elixir_mcp_sdk.ex          # Main SDK module
│   ├── protocol/                  # JSON-RPC protocol implementation
│   │   ├── request.ex            # Request DTOs and parsing
│   │   ├── response.ex           # Response DTOs and formatting
│   │   ├── notification.ex       # Notification handling
│   │   └── lifecycle.ex          # Initialize/initialized handshake
│   ├── transport/                # Transport abstractions
│   │   ├── stdio.ex             # Stdio transport implementation
│   │   ├── http.ex              # HTTP transport interface
│   │   └── framing.ex           # Message framing utilities
│   ├── server/                   # Server framework
│   │   ├── connection.ex        # Connection management
│   │   ├── router.ex            # Request routing
│   │   └── framework.ex         # Server utilities
│   └── client/                   # Client framework (future)
├── examples/
│   └── hello_world/             # Basic server example
├── docs/                        # Documentation
├── test/
├── mix.exs
├── README.md
└── AGENTS.md
```

## Phase 1: Core Protocol Infrastructure (Bare Bones)

**Goal**: Basic MCP server that accepts connections and handles initialization

### SDK Components to Build:

1. **Protocol Layer** (`lib/protocol/`)
   - `Request`, `Response`, `Notification` structs using stdlib JSON
   - JSON-RPC 2.0 message validation and parsing
   - MCP-specific error response formatting

2. **Transport Layer** (`lib/transport/`)
   - Stdio transport with message framing (newline-delimited JSON)
   - HTTP transport interface (callbacks, not implementation)
   - Message encoding/decoding using `:json.encode/1` and `:json.decode/1`

3. **Server Framework** (`lib/server/`)
   - Basic connection acceptance framework
   - Request dispatching system
   - Lifecycle management (initialize/initialized)

### Example Implementation (`examples/hello_world/`)
   - Minimal MCP server using SDK framework
   - Stdio transport for local testing
   - Responds to initialize requests with basic capabilities

### Key Deliverables:
- Working JSON-RPC message handling with stdlib JSON
- Stdio transport that can read/write MCP messages
- Basic server that accepts connections and completes initialization handshake
- Hello world example demonstrating connectivity

## Phase 2: Core Primitives - Tools

### SDK Extensions:

1. **Protocol Layer**
   - `tools/list` and `tools/call` message types
   - Tool definition structs and validation

2. **Server Framework**
   - Tool registration system
   - Tool execution framework
   - Tool result formatting

3. **Transport Layer**
   - Ensure tools work over both stdio and HTTP transports

### Example Implementation (`examples/calculator/`)
   - MCP server exposing calculator tools (add, multiply, etc.)
   - Demonstrates tool registration and execution
   - Tests both stdio and HTTP transport compatibility

## Phase 3: Additional Primitives - Resources & Prompts

### SDK Extensions:

1. **Protocol Layer**
   - `resources/list`, `resources/read`, `resources/subscribe` messages
   - `prompts/list`, `prompts/get` messages
   - Resource and prompt definition structs

2. **Server Framework**
   - Resource registration and retrieval system
   - Prompt template management
   - Subscription handling for resources

### Example Implementation (`examples/file_reader/`)
   - MCP server providing file system resources
   - Demonstrates resource access patterns
   - Shows prompt template usage

## Phase 4: HTTP Transport Implementation

### SDK Extensions:

1. **Transport Layer**
   - HTTP transport interface implementation
   - Streamable HTTP support for MCP
   - SSE (Server-Sent Events) for notifications

2. **Server Framework**
   - HTTP-specific connection management
   - Session handling for stateful HTTP connections

### Example Implementation (`examples/weather_api/`)
   - Full-featured MCP server using HTTP transport
   - Demonstrates real-world API integration
   - Shows notification streaming

## Phase 5: Client SDK

### New SDK Components:

1. **Client Framework** (`lib/client/`)
   - Client connection management
   - Server discovery utilities
   - Request/response handling for clients

2. **Transport Layer**
   - Client-side transport implementations
   - Connection pooling and management

### Integration Testing:
   - Examples updated to work with both server and client SDK
   - End-to-end testing between client and server implementations

## Phase 6: Production Features & Polish

### SDK Enhancements:

1. **Error Handling**
   - Comprehensive error types and handling
   - MCP-specific error codes and messages

2. **Configuration**
   - Configuration system for transports and servers
   - Environment-specific settings

3. **Security**
   - Authentication and authorization utilities
   - Input validation and sanitization

4. **Performance**
   - Connection pooling
   - Message batching optimizations

## Development Workflow

### Iterative Approach:
1. **Build SDK Component** → **Create/Update Example** → **Test Integration**
2. **Start Simple**: Hello world example validates basic connectivity
3. **Progressive Complexity**: Each example builds on previous functionality
4. **Dual Testing**: Examples serve as both tests and documentation

### Testing Strategy:
- **Unit Tests**: SDK components tested in isolation
- **Integration Tests**: Examples validate end-to-end functionality
- **Transport Tests**: Ensure compatibility across stdio and HTTP
- **Protocol Tests**: Validate MCP compliance

### Key Benefits:
- **Modular SDK**: Clean separation between protocol, transport, and framework
- **User Choice**: Transport abstractions allow flexible server implementations
- **Thoroughly Tested**: Examples provide real-world validation
- **Production Ready**: Focus on error handling, security, and performance

## Technical Decisions

### JSON Handling
- Use Elixir stdlib `:json` module (Elixir 1.18+)
- No external JSON dependencies
- Handle encoding/decoding errors gracefully

### Transport Architecture
- Provide transport abstractions, not implementations
- Users choose HTTP servers (Bandit, Cowboy, etc.)
- Support both stdio and HTTP transports

### Protocol Implementation
- Custom JSON-RPC 2.0 handling for MCP-specific requirements
- Full MCP lifecycle support (initialize/initialized)
- Comprehensive error handling with MCP error codes

### Server Framework
- Connection management utilities
- Request routing and dispatching
- Tool/resource/prompt registration systems

This plan provides a solid foundation for building a comprehensive MCP SDK while maintaining flexibility and avoiding unnecessary dependencies. The SDK focuses on the MCP protocol implementation while allowing users to choose their preferred HTTP server implementations.</content>
<parameter name="filePath">docs/DEVELOPMENT_PLAN.md