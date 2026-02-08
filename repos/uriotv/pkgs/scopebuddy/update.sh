#!/usr/bin/env bash
set -euo pipefail

# Get latest commit from main branch
# Get latest release tag
LATEST_TAG=$(curl -s https://api.github.com/repos/OpenGamingCollective/ScopeBuddy/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
CURRENT_VERSION=$(grep "version = " pkgs/scopebuddy/default.nix | sed 's/.*"\(.*\)".*/\1/')

if [ "$LATEST_TAG" = "$CURRENT_VERSION" ]; then
    echo "scopebuddy is up to date ($CURRENT_VERSION)"
    exit 0
fi

echo "Updating scopebuddy: $CURRENT_VERSION -> $LATEST_TAG"

# Get new hash using nix flake prefetch
HASH=$(nix flake prefetch "github:OpenGamingCollective/ScopeBuddy/$LATEST_TAG" --json 2>/dev/null | grep -o '"hash":"[^"]*"' | sed 's/"hash":"//;s/"//')

# Update rev, hash, and version in file
# We are switching from commit hash to tag for rev, and unstable date to tag for version
sed -i "s/rev = \".*\"/rev = \"${LATEST_TAG}\"/" pkgs/scopebuddy/default.nix
sed -i "s|hash = \"sha256-.*\"|hash = \"${HASH}\"|" pkgs/scopebuddy/default.nix
sed -i "s/version = \".*\"/version = \"${LATEST_TAG}\"/" pkgs/scopebuddy/default.nix

echo "Updated scopebuddy to $LATEST_TAG"
