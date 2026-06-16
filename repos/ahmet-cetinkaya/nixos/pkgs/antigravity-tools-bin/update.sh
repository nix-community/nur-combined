#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

#PINNED_VERSION="${PINNED_VERSION:-4.1.31}"

if [ -n "${PINNED_VERSION:-}" ]; then
	echo "📌 Pinned version: $PINNED_VERSION"
	TARGET_VERSION="$PINNED_VERSION"
else
	CURRENT_VERSION=$(grep 'version = "' default.nix | sed 's/.*version = "\(.*\)".*/\1/')
	echo "📌 Current version: $CURRENT_VERSION"

	VERSIONS_JSON=$(curl -sSL "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases")
	LATEST_VERSION=$(echo "$VERSIONS_JSON" | jq -r '.[0].tag_name' | sed 's/^v//')
	echo "🏷️  Latest version: $LATEST_VERSION"

	TARGET_VERSION="$LATEST_VERSION"
fi

if grep -q "version = \"$TARGET_VERSION\"" default.nix; then
	echo "✅ Already up to date"
	exit 0
fi

echo "🔐 Fetching SHA256..."
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT
curl -SLf "https://github.com/lbjlaq/Antigravity-Manager/releases/download/v${TARGET_VERSION}/Antigravity.Tools_${TARGET_VERSION}_amd64.deb" -o "$TMPFILE"
SHA256=$(sha256sum "$TMPFILE" | cut -d' ' -f1)
echo "🔐 SHA256: $SHA256"

sed -i "s|version = \".*\"|version = \"$TARGET_VERSION\"|" default.nix
sed -i "s|sha256 = \".*\"|sha256 = \"$SHA256\"|" default.nix

echo "✅ Updated default.nix"
