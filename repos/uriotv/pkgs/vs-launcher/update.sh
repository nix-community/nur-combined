#!/usr/bin/env bash
set -euo pipefail

# Get latest version from GitHub releases
# Filter specifically for tag_name and extract the value between quotes
LATEST=$(curl -s https://api.github.com/repos/XurxoMF/vs-launcher/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
CURRENT=$(grep 'version = ' pkgs/vs-launcher/default.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ "$LATEST" = "$CURRENT" ]; then
    echo "vs-launcher is up to date ($CURRENT)"
    exit 0
fi

echo "Updating vs-launcher: $CURRENT -> $LATEST"

# Get new hash using nix store prefetch-file
URL="https://github.com/XurxoMF/vs-launcher/releases/download/${LATEST}/vs-launcher-${LATEST}.AppImage"
HASH=$(nix store prefetch-file "$URL" --json 2>/dev/null | grep -o '"hash":"[^"]*"' | sed 's/"hash":"//;s/"//')

# Update version and hash in file
sed -i "s/version = \"${CURRENT}\"/version = \"${LATEST}\"/" pkgs/vs-launcher/default.nix
sed -i "s|sha256 = \".*\"|sha256 = \"${HASH}\"|" pkgs/vs-launcher/default.nix

echo "Updated vs-launcher to $LATEST"
