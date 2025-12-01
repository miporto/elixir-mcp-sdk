#!/usr/bin/env bash
# Run script for the Hello World HTTP server example

echo "Starting Hello World HTTP Server on port 4000..."
echo "Visit: http://localhost:4000/hello"
echo "Health check: http://localhost:4000/health"
echo "Press Ctrl+C to stop"

# Ensure we are in the example directory
cd "$(dirname "$0")"

# Get dependencies
mix deps.get

# Run the application
mix run --no-halt
