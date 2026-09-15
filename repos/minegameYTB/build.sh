#!/usr/bin/env bash
set -euo pipefail

if ! command -v nix >/dev/null 2>&1; then
  echo "error: 'nix' not found in PATH, install Nix first: https://nixos.org/download/" >&2
  exit 1
fi

nix develop --command make "$@"
