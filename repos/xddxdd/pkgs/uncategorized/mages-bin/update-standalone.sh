#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p nix
# shellcheck shell=bash
set -euo pipefail

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
OLD_VERSION=$(jq -r '."x86_64-linux".version' "$DIR/sources.json")

asset_url() {
    echo "https://github.com/mlm-games/Mages/releases/download/$1/mages-$1-$2.AppImage"
}

# Upstream publishes the tag before the AppImages, so walk the release list
# newest first and take the first tag whose assets are really uploaded.
FEED=$(curl -fsSL --retry 3 --retry-delay 5 https://github.com/mlm-games/Mages/releases.atom) || exit 1
NEW_VERSION=""
while IFS= read -r TAG; do
    if [ "$TAG" = "$OLD_VERSION" ]; then
        break
    fi
    if curl -fsIL --retry 3 --retry-delay 5 --max-time 60 "$(asset_url "$TAG" x86_64)" >/dev/null 2>&1 &&
        curl -fsIL --retry 3 --retry-delay 5 --max-time 60 "$(asset_url "$TAG" aarch64)" >/dev/null 2>&1; then
        NEW_VERSION="$TAG"
        break
    fi
    echo "skipping $TAG: AppImages are not uploaded yet" >&2
done < <(grep -oP '(?<=/tag/)[^"<]+' <<<"$FEED")
if [ -z "$NEW_VERSION" ]; then
    exit 0
fi

fetch_hash() {
    local OUT
    OUT=$(nix store prefetch-file --json "$1") || return 1
    jq -er .hash <<<"$OUT"
}

X86_64_URL=$(asset_url "$NEW_VERSION" x86_64)
AARCH64_URL=$(asset_url "$NEW_VERSION" aarch64)
X86_64_HASH=$(fetch_hash "$X86_64_URL")
AARCH64_HASH=$(fetch_hash "$AARCH64_URL")

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
