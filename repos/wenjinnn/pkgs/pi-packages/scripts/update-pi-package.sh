#!/usr/bin/env bash
# Script to update pi package hashes in the pi-packages set
# Usage: ./update-pi-package.sh <package-name> [version]
#
# Examples:
#   ./update-pi-package.sh pi-mcp-adapter
#   ./update-pi-package.sh @gotgenes/pi-subagents 11.3.0

set -euo pipefail

PACKAGE_NAME="${1:?Usage: $0 <package-name> [version]}"
VERSION="${2:-latest}"

# Get package info from npm registry
if [ "$VERSION" = "latest" ]; then
  INFO=$(curl -s "https://registry.npmjs.org/${PACKAGE_NAME}/latest")
  VERSION=$(echo "$INFO" | jq -r '.version')
  TARBALL_URL=$(echo "$INFO" | jq -r '.dist.tarball')
else
  INFO=$(curl -s "https://registry.npmjs.org/${PACKAGE_NAME}")
  TARBALL_URL=$(echo "$INFO" | jq -r ".versions[\"${VERSION}\"].dist.tarball")
fi

if [ -z "$TARBALL_URL" ] || [ "$TARBALL_URL" = "null" ]; then
  echo "Error: Could not find package ${PACKAGE_NAME} version ${VERSION}"
  exit 1
fi

echo "Package: ${PACKAGE_NAME}"
echo "Version: ${VERSION}"
echo "Tarball: ${TARBALL_URL}"

# Fetch and compute hash
echo "Fetching and computing hash..."
HASH=$(nix-prefetch-url --unpack "$TARBALL_URL" 2>/dev/null | xargs -I{} nix hash convert --to-sri --hash-algo sha256 {})

if [ -z "$HASH" ]; then
  # Fallback: download and compute hash manually
  echo "Trying alternative hash computation..."
  HASH="sha256-:$(curl -sL "$TARBALL_URL" | sha256sum | head -c 64)"
fi

echo ""
echo "Hash: ${HASH}"
echo ""
echo "Use this in your pi-packages/default.nix:"
echo ""
echo "  ${PACKAGE_NAME} = mkPiPackage {"
echo "    name = \"${PACKAGE_NAME##*/}\";"
echo "    version = \"${VERSION}\";"
echo "    hash = \"${HASH}\";"
echo "    description = \"...\";"
echo "    homepage = \"...\";"
echo "  };"
