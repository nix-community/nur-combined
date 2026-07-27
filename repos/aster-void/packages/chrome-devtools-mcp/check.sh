#!/usr/bin/env bash
set -euo pipefail

# MCP server with bwrap - just check wrapper exists
nix build .#chrome-devtools-mcp
test -x ./result/bin/chrome-devtools-mcp
