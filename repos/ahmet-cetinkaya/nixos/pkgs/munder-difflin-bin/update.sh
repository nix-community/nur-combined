#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CURRENT_VERSION=$(grep 'version = "' default.nix | sed 's/.*version = "\(.*\)".*/\1/')
echo "📌 Current version: $CURRENT_VERSION"

LATEST_VERSION=$(curl -sSL "https://api.github.com/repos/HarnessMD/munder-difflin/releases/latest" | grep -oP '"tag_name":\s*"v\K[^"]+')
echo "🏷️  Latest version: $LATEST_VERSION"

if [ -z "$LATEST_VERSION" ]; then
	echo "❌ Could not determine latest version"
	exit 1
fi

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
	echo "✅ Already up to date"
	exit 0
fi

echo "🔐 Prefetching AppImage..."
SRI_HASH=$(nix store prefetch-file --json \
	"https://github.com/HarnessMD/munder-difflin/releases/download/v${LATEST_VERSION}/Munder-Difflin-${LATEST_VERSION}-linux-x86_64.AppImage" \
	| grep -oP '"hash":\s*"\K[^"]+')
echo "🔐 SRI hash: $SRI_HASH"

sed -i "s|version = \".*\"|version = \"$LATEST_VERSION\"|" default.nix
sed -i "s|hash = \".*\"|hash = \"$SRI_HASH\"|" default.nix

echo "✅ Updated default.nix"
