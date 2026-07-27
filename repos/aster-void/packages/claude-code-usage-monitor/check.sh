#!/usr/bin/env bash
set -euo pipefail

nix run .#claude-code-usage-monitor -- --help
