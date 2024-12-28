#!/usr/bin/env bash

set -exuo pipefail

info=pkgs/zen-browser/metadata.json
latestVersion=$(curl -s "https://api.github.com/repos/zen-browser/desktop/releases/latest" | jq --raw-output '.tag_name | sub("^v"; "")')
currentVersion=$(jq -r '.version' "$info")

if [[ "$currentVersion" == "$latestVersion" ]]; then
  exit 0
fi

url="https://github.com/zen-browser/desktop/releases/download/$latestVersion/zen-x86_64.AppImage"

hash=$(nix-prefetch-url --type sha256 "$url" | xargs nix hash to-sri --type sha256)

jq --arg version "$latestVersion" \
  --arg hash "$hash" \
  '.version = $version | .hash = $hash' \
  "$info" >"${info}.tmp"

mv "${info}.tmp" "$info"
