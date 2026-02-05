#!/usr/bin/env bash
set -euo pipefail

PKG_FILE="pkgs/quarkpantool/default.nix"
API_URL="https://api.github.com/repos/ihmily/QuarkPanTool/releases/latest"

RELEASE_DATA=$(curl -sL "$API_URL")
# Use a here-string to avoid SIGPIPE with pipefail when grep exits early.
LATEST_TAG=$(grep -m1 '"tag_name":' <<<"$RELEASE_DATA" | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
  echo "Failed to fetch latest release tag."
  exit 1
fi

LATEST_VERSION="${LATEST_TAG#v}"
OLD_VERSION=$(grep -m1 'version = "' "$PKG_FILE" | sed -E 's/.*version = "([^"]+)".*/\1/')

echo "Current version: $OLD_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [ "$LATEST_VERSION" = "$OLD_VERSION" ]; then
  echo "Package is already up-to-date. No changes needed."
  exit 0
fi

SRC_URL="https://github.com/ihmily/QuarkPanTool/archive/refs/tags/${LATEST_TAG}.tar.gz"
NEW_HASH=$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --unpack "$SRC_URL")")

echo "Latest src hash: $NEW_HASH"

sed -i "s/version = \"$OLD_VERSION\";/version = \"$LATEST_VERSION\";/" "$PKG_FILE"
sed -i "s|hash = \"[^\"]*\";|hash = \"$NEW_HASH\";|" "$PKG_FILE"

echo "Update complete. The Nix expression is now pointing to version $LATEST_VERSION."
