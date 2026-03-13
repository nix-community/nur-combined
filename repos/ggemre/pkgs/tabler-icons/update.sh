#! /usr/bin/env bash
set -euo pipefail
nix run nixpkgs#nix-update -- tabler-icons --flake
