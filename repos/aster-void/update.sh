#!/usr/bin/env bash
set -euo pipefail

nix-update chrome-devtools-mcp.unwrapped -f nur.nix --commit
nix-update ccusage -f nur.nix --commit
nix-update ccusage-codex -f nur.nix --commit
nix-update ccusage-mcp -f nur.nix --commit
nix-update claude-code-usage-monitor -f nur.nix --commit
