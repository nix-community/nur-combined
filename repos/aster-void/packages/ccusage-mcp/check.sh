#!/usr/bin/env bash
set -euo pipefail

nix run .#ccusage-mcp -- --help
