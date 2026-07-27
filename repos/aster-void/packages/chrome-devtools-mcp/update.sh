#!/usr/bin/env bash
set -euo pipefail

nix-update chrome-devtools-mcp.unwrapped --flake --commit
