#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CURRENT_VERSION=$(grep 'version = "' default.nix | sed 's/.*version = "\(.*\)".*/\1/')
echo "📌 Current version: $CURRENT_VERSION"

LATEST_TAG=$(curl -sSL "https://api.github.com/repos/theinvisible/openfortigui/tags" | jq -r '.[0].name')
LATEST_VERSION=$(echo "$LATEST_TAG" | sed 's/^v//; s/-[0-9]*$//')
echo "🏷️  Latest version: $LATEST_VERSION (tag: $LATEST_TAG)"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
	echo "✅ Already up to date"
	exit 0
fi

echo "🔐 Fetching SRI hash (with submodules)..."
SRI_HASH=$(nix flake prefetch --json "github:theinvisible/openfortigui/$LATEST_TAG" 2>/dev/null | jq -r '.hash')
echo "🔐 SRI hash: $SRI_HASH"

sed -i "s|version = \".*\"|version = \"$LATEST_VERSION\"|" default.nix
sed -i "s|hash = \".*\"|hash = \"$SRI_HASH\"|" default.nix

echo "✅ Updated default.nix"
