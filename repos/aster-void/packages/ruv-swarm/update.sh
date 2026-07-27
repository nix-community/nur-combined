#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

echo "Fetching latest commit from ruvnet/ruv-FANN..."
LATEST_REV=$(curl -s "https://api.github.com/repos/ruvnet/ruv-FANN/commits/main" | jq -r '.sha')

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
sed -i "s|rev = \"$CURRENT_REV\"|rev = \"$LATEST_REV\"|" "$PACKAGE_FILE"

# Set src hash to empty to trigger hash mismatch
sed -i '0,/hash = "sha256-[^"]*"/s//hash = ""/' "$PACKAGE_FILE"

# Build to get correct src hash
echo "Building to get correct src hash..."
BUILD_OUTPUT=$(nix build .#ruv-swarm 2>&1 || true)

# Extract the correct hash from error message
CORRECT_HASH=$(echo "$BUILD_OUTPUT" | grep -oP 'got:\s+\Ksha256-[A-Za-z0-9+/=]+' | head -1)

if [ -z "$CORRECT_HASH" ]; then
  echo "Error: Failed to get correct src hash from build output" >&2
  echo "$BUILD_OUTPUT" >&2
  exit 1
fi

echo "Correct src hash: $CORRECT_HASH"

# Update src hash (first occurrence)
sed -i "0,/hash = \"\"/s||hash = \"$CORRECT_HASH\"|" "$PACKAGE_FILE"

# Now update pnpmDeps hash - set to empty
sed -i 's|pnpmDeps = pnpm.fetchDeps {|pnpmDeps = pnpm.fetchDeps {\n    # TEMP_MARKER|' "$PACKAGE_FILE"
sed -i '/TEMP_MARKER/,/hash = "sha256-[^"]*"/{s/hash = "sha256-[^"]*"/hash = ""/}' "$PACKAGE_FILE"
sed -i '/# TEMP_MARKER/d' "$PACKAGE_FILE"

# Build again to get pnpmDeps hash
echo "Building to get correct pnpmDeps hash..."
BUILD_OUTPUT=$(nix build .#ruv-swarm 2>&1 || true)

PNPM_HASH=$(echo "$BUILD_OUTPUT" | grep -oP 'got:\s+\Ksha256-[A-Za-z0-9+/=]+' | head -1)

if [ -z "$PNPM_HASH" ]; then
  echo "Error: Failed to get correct pnpmDeps hash from build output" >&2
  echo "$BUILD_OUTPUT" >&2
  exit 1
fi

echo "Correct pnpmDeps hash: $PNPM_HASH"

# Update pnpmDeps hash
sed -i "s|hash = \"\"|hash = \"$PNPM_HASH\"|" "$PACKAGE_FILE"

nix fmt "$PACKAGE_FILE" 2>/dev/null || true

echo "Updated ruv-swarm from ${CURRENT_REV:0:7} to ${LATEST_REV:0:7}"

# Commit the change
git add "$PACKAGE_FILE"
git commit -m "packages/ruv-swarm: ${CURRENT_REV:0:7} -> ${LATEST_REV:0:7}"
