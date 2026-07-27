#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

echo "Fetching latest commit from aster-void/zz..."
LATEST_REV=$(curl -s "https://api.github.com/repos/aster-void/zz/commits/main" | jq -r '.sha')

if [ -z "$LATEST_REV" ] || [ "$LATEST_REV" = "null" ]; then
  echo "Error: Failed to fetch latest commit hash" >&2
  exit 1
fi

echo "Latest revision: $LATEST_REV"

CURRENT_REV=$(grep -oP 'rev = "\K[^"]+' "$PACKAGE_FILE")
echo "Current revision: $CURRENT_REV"

if [ "$CURRENT_REV" = "$LATEST_REV" ]; then
  echo "Already up to date!"
  exit 0
fi

# Update rev
sed -i "s/rev = \"$CURRENT_REV\"/rev = \"$LATEST_REV\"/" "$PACKAGE_FILE"

# Set hash to empty to trigger hash mismatch
sed -i 's/hash = "sha256-[^"]*"/hash = ""/' "$PACKAGE_FILE"

# Build to get correct hash
echo "Building to get correct hash..."
BUILD_OUTPUT=$(nix build .#zz 2>&1 || true)

# Extract the correct hash from error message
CORRECT_HASH=$(echo "$BUILD_OUTPUT" | grep -oP 'got:\s+\Ksha256-[A-Za-z0-9+/=]+' | head -1)

if [ -z "$CORRECT_HASH" ]; then
  echo "Error: Failed to get correct hash from build output" >&2
  echo "$BUILD_OUTPUT" >&2
  exit 1
fi

echo "Correct hash: $CORRECT_HASH"

# Update hash
sed -i "s|hash = \"\"|hash = \"$CORRECT_HASH\"|" "$PACKAGE_FILE"

nix fmt "$PACKAGE_FILE" 2>/dev/null || true

echo "Updated zz from $CURRENT_REV to $LATEST_REV"

# Commit the change
git add "$PACKAGE_FILE"
git commit -m "packages/zz: ${CURRENT_REV:0:7} -> ${LATEST_REV:0:7}"
