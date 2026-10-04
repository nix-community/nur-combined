#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p coreutils -p curl -p gnugrep -p nix -p nix-update
# shellcheck shell=bash
set -euo pipefail

NEW_VERSION=$(
  curl -fsSL https://github.com/mikespub-org/seblucas-cops/releases.atom |
    grep -oP 'releases/tag/\K[^"]+' |
    while read -r tag; do
      if curl -fsIL -o /dev/null "https://github.com/mikespub-org/seblucas-cops/releases/download/$tag/cops-$tag-php84.zip"; then
        echo "$tag"
      fi
    done |
    sort -V |
    tail -n1
)

if [ -z "$NEW_VERSION" ] || [ "$NEW_VERSION" = "${UPDATE_NIX_OLD_VERSION:-}" ]; then
  exit 0
fi

exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
