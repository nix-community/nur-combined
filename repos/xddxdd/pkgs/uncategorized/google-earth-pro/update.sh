#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p nix-update
# shellcheck shell=bash
set -euo pipefail

NEW_VERSION=$(curl -fsSL 'https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=google-earth-pro' |
  jq -r '.results[0].Version' | sed 's/-[^-]*$//')
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
