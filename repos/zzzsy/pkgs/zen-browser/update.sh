#!/usr/bin/env bash

set -exuo pipefail

info=pkgs/zen-browser/metadata.json
latestVersion=$(curl -s "https://api.github.com/repos/zen-browser/desktop/releases/latest" | jq --raw-output '.tag_name | sub("^v"; "")')
currentVersion=$(jq -r '.version' "$info")

if [[ "$currentVersion" == "$latestVersion" ]]; then
  exit 0
fi

url1="https://github.com/zen-browser/desktop/releases/download/$latestVersion/zen-generic.AppImage"
url2="https://github.com/zen-browser/desktop/releases/download/$latestVersion/zen-specific.AppImage"

hash1=$(nix-prefetch-url --type sha256 "$url1" | xargs nix hash to-sri --type sha256)
hash2=$(nix-prefetch-url --type sha256 "$url2" | xargs nix hash to-sri --type sha256)

jq --arg version "$latestVersion" \
  --arg generic "$hash1" \
  --arg specific "$hash2" \
  '.version = $version | .generic = $generic | .specific = $specific' \
  "$info" >"${info}.tmp"

mv "${info}.tmp" "$info"
