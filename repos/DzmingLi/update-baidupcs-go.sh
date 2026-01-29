#!/usr/bin/env bash
set -euo pipefail

PKG_FILE="pkgs/baidupcs-go/default.nix"
API_URL="https://api.github.com/repos/qjfoidnh/BaiduPCS-Go/releases/latest"

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

SRC_URL="https://github.com/qjfoidnh/BaiduPCS-Go/archive/refs/tags/${LATEST_TAG}.tar.gz"
NEW_HASH=$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --unpack "$SRC_URL")")

echo "Latest src hash: $NEW_HASH"

sed -i "s/version = \"$OLD_VERSION\";/version = \"$LATEST_VERSION\";/" "$PKG_FILE"
sed -i "s|hash = \"[^\"]*\";|hash = \"$NEW_HASH\";|" "$PKG_FILE"

PLACEHOLDER_VENDOR_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
sed -i "s|vendorHash = \"[^\"]*\";|vendorHash = \"$PLACEHOLDER_VENDOR_HASH\";|" "$PKG_FILE"

echo "Calculating vendorHash..."
BUILD_OUTPUT=$(nix build .#baidupcs-go --no-link 2>&1 || true)
VENDOR_HASH=$(echo "$BUILD_OUTPUT" | grep -m1 -o 'got: sha256-[A-Za-z0-9+/=]*' | sed -E 's/.*got: (sha256-[A-Za-z0-9+/=]*).*/\1/')

if [ -z "$VENDOR_HASH" ]; then
  echo "Failed to determine vendorHash. Build output:"
  echo "$BUILD_OUTPUT"
  exit 1
fi

sed -i "s|vendorHash = \"$PLACEHOLDER_VENDOR_HASH\";|vendorHash = \"$VENDOR_HASH\";|" "$PKG_FILE"
echo "Updated vendorHash: $VENDOR_HASH"
