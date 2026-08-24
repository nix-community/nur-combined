#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p gnused -p nix -p nix-update
# shellcheck shell=bash
set -euo pipefail

NEW_VERSION=$(curl -fsSL 'https://github.com/wuhgit/CustomPinyinDictionary/releases/expanded_assets/assets' | grep -oP 'CustomPinyinDictionary_Fcitx_Magisk_\K[0-9]+(?=\.zip)' | head -n1 || true)
if [ -z "$NEW_VERSION" ]; then
  echo "Failed to detect new version" >&2
  exit 1
fi
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
