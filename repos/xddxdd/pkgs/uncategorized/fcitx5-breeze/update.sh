#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p nix-update
# shellcheck shell=bash
set -euo pipefail

NEW_VERSION=$(curl -fsSL 'https://gitlab.com/api/v4/projects/53966606/releases/' | grep -oP 'https://gitlab\.com/scratch-er/fcitx5-breeze/-/archive/v\K[0-9.]+(?=/fcitx5-breeze-)' | head -n1 || true)
if [ -z "$NEW_VERSION" ]; then
  echo "Failed to detect new version" >&2
  exit 1
fi
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
