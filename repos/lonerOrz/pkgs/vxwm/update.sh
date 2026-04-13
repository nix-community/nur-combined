#!/usr/bin/env bash
set -euo pipefail

OWNER="wh1tepearl"
REPO="vxwm"
PKG_FILE="default.nix"
BUILD_TARGET=".#${REPO}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# 0️⃣ Check if update is needed
# =============================================================================

echo "→ Checking for updates..."

# Fetch latest commit from Codeberg
LATEST_REV=$(git ls-remote "https://codeberg.org/${OWNER}/${REPO}" refs/heads/main 2>/dev/null | cut -f1)

if [ -z "$LATEST_REV" ]; then
  echo "✗ Failed to fetch latest commit hash."
  exit 1
fi

PKG_PATH="$SCRIPT_DIR/$PKG_FILE"
CURRENT_REV="$(grep -oP 'rev\s*=\s*"\K[^"]+' "$PKG_PATH" || true)"

if [[ "$LATEST_REV" == "$CURRENT_REV" ]]; then
  echo "✓ Already up to date (rev: $CURRENT_REV)"
  exit 0
fi

echo "✓ Update available"
echo "  current: $CURRENT_REV"
echo "  latest:  $LATEST_REV"

# =============================================================================
# 1️⃣ Generate version number
# =============================================================================

VERSION="0-unstable-$(date +%F)"

# =============================================================================
# 2️⃣ Fetch SRI hash (using nix-prefetch-git with submodules)
# =============================================================================

HASH=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" \
  "https://codeberg.org/$OWNER/$REPO" --git --fetch-submodules)

# =============================================================================
# 3️⃣ Update rev/version/hash
# =============================================================================

sed -i -E "/pname\s*=\s*\"vxwm\"/,/^}/ {
  s|(rev\s*=\s*\")[^\"]*(\";)|\1$LATEST_REV\2|
  s|(version\s*=\s*\")[^\"]*(\";)|\1$VERSION\2|
  s|(hash\s*=\s*\")[^\"]*(\";)|\1$HASH\2|
}" "$PKG_PATH"

echo ""
echo "Updated $PKG_FILE:"
echo "  version: $VERSION"
echo "  rev:     $LATEST_REV"
echo "  hash:    $HASH"
