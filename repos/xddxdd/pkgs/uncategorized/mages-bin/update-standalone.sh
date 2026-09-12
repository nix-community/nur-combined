#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p nix
# shellcheck shell=bash
set -euo pipefail

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

NEW_VERSION=$(curl -fsSL https://github.com/mlm-games/Mages/releases.atom |
  grep -oP '(?<=/tag/)[^"<]+' | head -n1)
OLD_VERSION=$(jq -r '."x86_64-linux".version' "$DIR/sources.json")
if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
  exit 0
fi

X86_64_URL="https://github.com/mlm-games/Mages/releases/download/$NEW_VERSION/mages-$NEW_VERSION-x86_64.AppImage"
AARCH64_URL="https://github.com/mlm-games/Mages/releases/download/$NEW_VERSION/mages-$NEW_VERSION-aarch64.AppImage"
X86_64_HASH=$(nix store prefetch-file --json "$X86_64_URL" | jq -r .hash)
AARCH64_HASH=$(nix store prefetch-file --json "$AARCH64_URL" | jq -r .hash)

jq -n \
  --arg version "$NEW_VERSION" \
  --arg x86_64_url "$X86_64_URL" \
  --arg x86_64_hash "$X86_64_HASH" \
  --arg aarch64_url "$AARCH64_URL" \
  --arg aarch64_hash "$AARCH64_HASH" \
  '{
    "aarch64-linux": {hash: $aarch64_hash, url: $aarch64_url, version: $version},
    "x86_64-linux": {hash: $x86_64_hash, url: $x86_64_url, version: $version}
  }' >"$DIR/sources.json"
