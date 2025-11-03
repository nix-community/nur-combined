#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-github git coreutils gnused

# shellcheck shell=bash
set -euo pipefail

cd "$(dirname "$0")"

OWNER="Jojo-Schmitz"
REPO="MuseScore"
BRANCH="3.x"

if [ -n "${GITHUB_TOKEN:-}" ]; then
    TOKEN_ARGS=(--header "Authorization: token $GITHUB_TOKEN")
else
    TOKEN_ARGS=()
fi

# Get latest commit from 3.x branch
LATEST_COMMIT=$(curl -s "${TOKEN_ARGS[@]}" "https://api.github.com/repos/$OWNER/$REPO/commits/$BRANCH" | jq -r '.sha')
LATEST_DATE=$(curl -s "${TOKEN_ARGS[@]}" "https://api.github.com/repos/$OWNER/$REPO/commits/$LATEST_COMMIT" | jq -r '.commit.committer.date')

# Convert date from ISO format to YYYY-MM-DD
LATEST_DATE_SHORT=$(echo "$LATEST_DATE" | cut -d'T' -f1)

# Get current commit from default.nix
CURRENT_COMMIT=$(grep -oP '(?<=rev = ")[^"]*' default.nix)

if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
    echo "Already up to date at commit $LATEST_COMMIT"
    exit 0
fi

echo "Updating from $CURRENT_COMMIT to $LATEST_COMMIT"

# Fetch new hash using nix-prefetch-github
HASH_OUTPUT=$(nix-prefetch-github --rev "$LATEST_COMMIT" "$OWNER" "$REPO")
NEW_HASH=$(echo "$HASH_OUTPUT" | jq -r '.hash')

# Update version (unstable version based on date)
VERSION="3.6.2-unstable-$LATEST_DATE_SHORT"

# Update default.nix
sed -i "s|version = \".*\"; # version = \"3.6.2\";|version = \"$VERSION\"; # version = \"3.6.2\";|" default.nix
sed -i "s|rev = \".*\"; # rev = \"v\\\${version}\"; # 3.6.2|rev = \"$LATEST_COMMIT\"; # rev = \"v\\\${version}\"; # 3.6.2|" default.nix
sed -i "s|hash = \".*\"; # sha256 = \"sha256-GBGAD/qdOhoNfDzI+O0EiKgeb86GFJxpci35T6tZ+2s=\";|hash = \"$NEW_HASH\"; # sha256 = \"sha256-GBGAD/qdOhoNfDzI+O0EiKgeb86GFJxpci35T6tZ+2s=\";|" default.nix

echo "Updated to version $VERSION"
echo "Commit: $LATEST_COMMIT"
echo "Hash: $NEW_HASH"

# Optionally commit changes
if command -v git &> /dev/null && [ -d "../../.git" ]; then
    git add default.nix
    git commit -m "musescore3: unstable-$(echo $CURRENT_COMMIT | cut -c1-9) -> unstable-$(echo $LATEST_COMMIT | cut -c1-9)" || true
fi
