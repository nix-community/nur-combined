#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p nix-update
# shellcheck shell=bash
set -euo pipefail

NEW_VERSION=$(curl -fsSL 'https://api.github.com/repos/phpmyadmin/phpmyadmin/tags?per_page=100' |
  jq -r '.[].name' | grep -oP '^RELEASE_\K[0-9_]+' |
  awk -F_ '{print $1 "." $2 "." $3}' | sort -V | tail -n1 || true)
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
