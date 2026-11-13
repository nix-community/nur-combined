#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

base_url="https://persistent.oaistatic.com/codex-app-prod/linux/deb"
metadata=$(curl -fsSL --connect-timeout 15 --max-time 60 "$base_url/dists/stable/main/binary-amd64/Packages.gz" | gzip -dc)
get_field() {
  sed -n "s/^$1: //p" <<<"$metadata" | head -n 1
}
[[ $(get_field Package) == chatgpt && $(get_field Architecture) == amd64 ]]
NEW_VERSION=$(get_field Version)
filename=$(get_field Filename)
if [[ ! $NEW_VERSION =~ ^[0-9]+(\.[0-9]+)+$ || $filename != "pool/main/c/chatgpt/chatgpt_${NEW_VERSION}_amd64.deb" ]]; then
  echo "Invalid ChatGPT version or download path" >&2
  exit 1
fi
if [[ -n ${UPDATE_NIX_OLD_VERSION:-} && $NEW_VERSION != "$UPDATE_NIX_OLD_VERSION" &&
  $(printf '%s\n%s\n' "$NEW_VERSION" "$UPDATE_NIX_OLD_VERSION" | sort -V | head -n 1) == "$NEW_VERSION" ]]; then
  echo "Refusing to downgrade from $UPDATE_NIX_OLD_VERSION to $NEW_VERSION" >&2
  exit 1
fi
exec nix-update "$UPDATE_NIX_ATTR_PATH" --version "$NEW_VERSION"
