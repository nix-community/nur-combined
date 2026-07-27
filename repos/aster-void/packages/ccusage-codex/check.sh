#!/usr/bin/env bash
set -euo pipefail

nix run .#ccusage-codex -- --help
