#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p gnused -p nix -p nix-update
# shellcheck shell=bash
set -euo pipefail

NEW_VERSION=$(curl -fsSL 'https://github.com/phpmyadmin/phpmyadmin/tags.atom' |
  grep -oP '<id>tag:github\.com,2008:Repository/[0-9]+/\K[^<]+' |
  grep -oP '^RELEASE_\K[0-9_]+' |
  awk -F_ '{print $1 "." $2 "." $3}' | sort -V | tail -n1 || true)
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
