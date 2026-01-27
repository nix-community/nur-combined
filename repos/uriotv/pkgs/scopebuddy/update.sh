#!/usr/bin/env bash
set -euo pipefail

# Get latest commit from main branch
LATEST=$(curl -s https://api.github.com/repos/HikariKnight/ScopeBuddy/commits/main | grep '"sha"' | head -1 | sed 's/.*"\([a-f0-9]\{40\}\)".*/\1/')
CURRENT=$(grep "rev = " pkgs/scopebuddy/default.nix | sed 's/.*"\(.*\)".*/\1/')

if [ "$LATEST" = "$CURRENT" ]; then
    echo "scopebuddy is up to date ($CURRENT)"
    exit 0
fi

echo "Updating scopebuddy: ${CURRENT:0:7} -> ${LATEST:0:7}"

# Get new hash using nix flake prefetch
HASH=$(nix flake prefetch "github:HikariKnight/ScopeBuddy/$LATEST" --json 2>/dev/null | grep -o '"hash":"[^"]*"' | sed 's/"hash":"//;s/"//')
DATE=$(date +%Y-%m-%d)

# Update rev, hash, and version in file
sed -i "s/rev = \"${CURRENT}\"/rev = \"${LATEST}\"/" pkgs/scopebuddy/default.nix
sed -i "s|hash = \"sha256-.*\"|hash = \"${HASH}\"|" pkgs/scopebuddy/default.nix
sed -i "s/version = \"unstable-.*\"/version = \"unstable-${DATE}\"/" pkgs/scopebuddy/default.nix

echo "Updated scopebuddy to ${LATEST:0:7} (${DATE})"
