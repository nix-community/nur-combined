#!/usr/bin/env bash
#! nix-shell -i bash --pure --keep GITHUB_TOKEN -p nix git curl nix-prefetch-git prefetch-npm-deps

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/default.nix"
REPO_OWNER="vicinaehq/vicinae"
REPO_URL="https://github.com/${REPO_OWNER}"

echo "🔍 Fetching latest release from GitHub..."
LATEST_TAG=$("$SCRIPT_DIR/../../.github/script/github-tag-fetch.sh" "$REPO_OWNER")
echo "Latest tag: $LATEST_TAG"

OLD_TAG=$(nix eval --raw ".#vicinae.src.tag")
echo "Current tag: $OLD_TAG"

if [ "$OLD_TAG" = "$LATEST_TAG" ]; then
  echo "✅ Already up-to-date."
  exit 0
fi

echo "⬇️ Downloading source for tag $LATEST_TAG..."

SRC_HASH=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "$REPO_URL/archive/refs/tags/$LATEST_TAG.tar.gz" --unpack)
echo "Source hash: $SRC_HASH"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git clone --branch "$LATEST_TAG" --depth 1 "$REPO_URL" "$TMP/src"

echo "📦 Prefetching npm deps for API..."
cd "$TMP/src/src/typescript/api"
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
sed -i "s|srcHash = \".*\";|srcHash = \"$SRC_HASH\";|" $PACKAGE_NIX
sed -i "s|apiDepsHash = \".*\";|apiDepsHash = \"$API_HASH\";|" $PACKAGE_NIX
sed -i "s|extensionManagerDepsHash = \".*\";|extensionManagerDepsHash = \"$EXT_HASH\";|" $PACKAGE_NIX

echo "✅ vicinae.nix updated successfully!"
