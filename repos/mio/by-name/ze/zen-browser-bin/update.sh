#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${1:-}" ]]; then
  nix flake lock --override-input zen-browser-flake "github:0xc000022070/zen-browser-flake/$1"
else
  nix flake update zen-browser-flake
fi
