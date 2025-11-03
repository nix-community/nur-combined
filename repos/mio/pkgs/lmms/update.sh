#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-github git coreutils gnused

# shellcheck shell=bash
set -euo pipefail

cd "$(dirname "$0")"

OWNER="LMMS"
REPO="lmms"
BRANCH="master"

if [ -n "${GITHUB_TOKEN:-}" ]; then
    TOKEN_ARGS=(--header "Authorization: token $GITHUB_TOKEN")
else
    TOKEN_ARGS=()
fi

# Get latest commit from master branch
LATEST_COMMIT=$(curl -s "${TOKEN_ARGS[@]}" "https://api.github.com/repos/$OWNER/$REPO/commits/$BRANCH" | jq -r '.sha')
LATEST_DATE=$(curl -s "${TOKEN_ARGS[@]}" "https://api.github.com/repos/$OWNER/$REPO/commits/$LATEST_COMMIT" | jq -r '.commit.committer.date')

# Convert date from ISO format to YYYY-MM-DD
LATEST_DATE_SHORT=$(echo "$LATEST_DATE" | cut -d'T' -f1)

# Get current commit from package.nix
CURRENT_COMMIT=$(grep -oP '(?<=rev = ")[^"]*' package.nix)

if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
    echo "Already up to date at commit $LATEST_COMMIT"
    exit 0
fi

echo "Updating from $CURRENT_COMMIT to $LATEST_COMMIT"

# Fetch new hash using nix-prefetch-github
HASH_OUTPUT=$(nix-prefetch-github --rev "$LATEST_COMMIT" --fetch-submodules "$OWNER" "$REPO")
NEW_HASH=$(echo "$HASH_OUTPUT" | jq -r '.hash')

# Update version (unstable version based on date)
VERSION="1.2.2-unstable-$LATEST_DATE_SHORT"

# Update package.nix
sed -i "s|version = \".*\";|version = \"$VERSION\";|" package.nix
sed -i "s|rev = \".*\";|rev = \"$LATEST_COMMIT\";|" package.nix
sed -i "s|hash = \".*\";|hash = \"$NEW_HASH\";|" package.nix

echo "Updated to version $VERSION"
echo "Commit: $LATEST_COMMIT"
echo "Hash: $NEW_HASH"

# Optionally commit changes
if command -v git &> /dev/null && [ -d "../../.git" ]; then
    git add package.nix
    git commit -m "lmms: unstable-$(echo $CURRENT_COMMIT | cut -c1-9) -> unstable-$(echo $LATEST_COMMIT | cut -c1-9)" || true
fi
