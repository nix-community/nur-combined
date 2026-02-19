#!/usr/bin/env bash
set -euo pipefail

# cybergrub2077 tracks the "base" branch (no tags), so we use --version=branch
nix-update --flake cybergrub2077 --version=branch
