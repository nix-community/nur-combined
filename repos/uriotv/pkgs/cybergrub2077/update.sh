#!/usr/bin/env bash
set -euo pipefail

# Get latest commit from base branch (default branch)
LATEST=$(curl -s https://api.github.com/repos/adnksharp/CyberGRUB-2077/commits/base | grep '"sha"' | head -1 | sed 's/.*"\([a-f0-9]\{40\}\)".*/\1/')
CURRENT=$(grep "rev = " pkgs/cybergrub2077/default.nix | sed 's/.*"\(.*\)".*/\1/')

if [ -z "$LATEST" ]; then
    echo "Error: Could not fetch latest commit"
    exit 1
fi

if [ "$LATEST" = "$CURRENT" ]; then
    echo "cybergrub2077 is up to date ($CURRENT)"
    exit 0
fi

echo "Updating cybergrub2077: ${CURRENT:0:7} -> ${LATEST:0:7}"

# Get new hash using nix flake prefetch
HASH=$(nix flake prefetch "github:adnksharp/CyberGRUB-2077/$LATEST" --json 2>/dev/null | grep -o '"hash":"[^"]*"' | sed 's/"hash":"//;s/"//')
DATE=$(date +%Y-%m-%d)

# Update rev, hash, and version in file
sed -i "s/rev = \"${CURRENT}\"/rev = \"${LATEST}\"/" pkgs/cybergrub2077/default.nix
sed -i "s|sha256 = \"sha256-.*\"|sha256 = \"${HASH}\"|" pkgs/cybergrub2077/default.nix
sed -i "s/version = \"unstable-.*\"/version = \"unstable-${DATE}\"/" pkgs/cybergrub2077/default.nix

echo "Updated cybergrub2077 to ${LATEST:0:7} (${DATE})"
