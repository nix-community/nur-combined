#!/usr/bin/env bash
#! nix-shell -i bash --pure --keep GITHUB_TOKEN -p nix git curl nix-prefetch-git prefetch-npm-deps

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/default.nix"
REPO="https://github.com/vicinaehq/vicinae"

echo "🔍 Fetching latest release from GitHub..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/vicinaehq/vicinae/releases/latest" | jq -r .tag_name)
echo "Latest tag: $LATEST_TAG"

OLD_TAG=$(nix eval --raw ".#vicinae.src.tag")
echo "Current tag: $OLD_TAG"

if [ "$OLD_TAG" = "$LATEST_TAG" ]; then
  echo "✅ Already up-to-date."
  exit 0
fi

echo "⬇️ Downloading source for tag $LATEST_TAG..."

RAW_SRC_HASH=$(nix-prefetch-git --quiet --url "$REPO" --rev "$LATEST_TAG" | jq -r .sha256)
SRC_HASH=$(nix hash to-base64 "sha256:$RAW_SRC_HASH")
echo "Source hash: sha256-$SRC_HASH"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git clone --branch "$LATEST_TAG" --depth 1 "$REPO" "$TMP/src"

echo "📦 Prefetching npm deps for API..."
cd "$TMP/src/typescript/api"
API_HASH=$(prefetch-npm-deps package-lock.json)
# API_HASH=$(nix hash to-base64 "sha256:$RAW_API_HASH")
echo "api hash: $API_HASH"

echo "📦 Prefetching npm deps for Extension Manager..."
cd ../extension-manager
EXT_HASH=$(prefetch-npm-deps package-lock.json)
# EXT_HASH=$(nix hash to-base64 "sha256:$RAW_EXT_HASH")
echo "ext hash: $EXT_HASH"

cd ../..

sed -i "s|version = \".*\";|version = \"${LATEST_TAG#v}\";|" $PACKAGE_NIX
sed -i "s|srcHash = \".*\";|srcHash = \"sha256-$SRC_HASH\";|" $PACKAGE_NIX
sed -i "s|apiDepsHash = \".*\";|apiDepsHash = \"$API_HASH\";|" $PACKAGE_NIX
sed -i "s|extensionManagerDepsHash = \".*\";|extensionManagerDepsHash = \"$EXT_HASH\";|" $PACKAGE_NIX

echo "✅ vicinae.nix updated successfully!"
