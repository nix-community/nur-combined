#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

page=$(curl -fsSL --connect-timeout 15 --max-time 60 'https://lceda.cn/page/download')
versions=$(printf '%s\n' "$page" | grep -oE 'lceda-pro-linux-x64-[0-9]+(\.[0-9]+)+\.zip' | sort -u)
if [[ $(printf '%s\n' "$versions" | wc -l) -ne 1 || -z $versions ]]; then
  echo "Expected exactly one Linux x64 download on the official page" >&2
  exit 1
fi
NEW_VERSION=${versions#lceda-pro-linux-x64-}
NEW_VERSION=${NEW_VERSION%.zip}
if [[ -n ${UPDATE_NIX_OLD_VERSION:-} && $NEW_VERSION != "$UPDATE_NIX_OLD_VERSION" &&
  $(printf '%s\n%s\n' "$NEW_VERSION" "$UPDATE_NIX_OLD_VERSION" | sort -V | head -n 1) == "$NEW_VERSION" ]]; then
  echo "Refusing to downgrade from $UPDATE_NIX_OLD_VERSION to $NEW_VERSION" >&2
  exit 1
fi
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
