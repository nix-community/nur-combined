#!/usr/bin/env bash
set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

# Fetch the latest commit hash from gj1118/helix repository
echo "Fetching latest commit from gj1118/helix..."
LATEST_REV=$(curl -s "https://api.github.com/repos/gj1118/helix/commits/master" | jq -r '.sha')

if [ -z "$LATEST_REV" ] || [ "$LATEST_REV" = "null" ]; then
  echo "Error: Failed to fetch latest commit hash" >&2
  exit 1
fi

echo "Latest revision: $LATEST_REV"

# Get current revision from package.nix
CURRENT_REV=$(grep -oP 'rev = "\K[^"]+' "$PACKAGE_FILE")
echo "Current revision: $CURRENT_REV"

if [ "$CURRENT_REV" = "$LATEST_REV" ]; then
  echo "Already up to date!"
  exit 0
fi

# Update the revision in package.nix
echo "Updating package.nix..."
sed -i "s/rev = \"$CURRENT_REV\"/rev = \"$LATEST_REV\"/" "$PACKAGE_FILE"

# Format with nix fmt
echo "Formatting with nix fmt..."
nix fmt "$PACKAGE_FILE" 2>/dev/null || true

echo "Updated helix-gj1118 from $CURRENT_REV to $LATEST_REV"

# Commit the change
git add "$PACKAGE_FILE"
git commit -m "packages/helix-gj1118: ${CURRENT_REV:0:7} -> ${LATEST_REV:0:7}"
