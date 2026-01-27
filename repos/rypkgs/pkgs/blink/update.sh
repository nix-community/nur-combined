#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-github git coreutils gnused nix

# shellcheck shell=bash
set -euo pipefail

cd "$(dirname "$0")"
REPO_ROOT=$(git rev-parse --show-toplevel)

OWNER="prayag17"
REPO="Blink"

if [ -n "${GITHUB_TOKEN:-}" ]; then
    AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
else
    AUTH_HEADER=""
fi

# Get latest release tag
echo "Fetching latest release..."
if [ -n "$AUTH_HEADER" ]; then
    LATEST_TAG=$(curl -s -H "$AUTH_HEADER" "https://api.github.com/repos/$OWNER/$REPO/releases/latest" | jq -r '.tag_name')
else
    LATEST_TAG=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases/latest" | jq -r '.tag_name')
fi

if [ "$LATEST_TAG" = "null" ] || [ -z "$LATEST_TAG" ]; then
    echo "Could not fetch latest release, trying tags..."
    if [ -n "$AUTH_HEADER" ]; then
        LATEST_TAG=$(curl -s -H "$AUTH_HEADER" "https://api.github.com/repos/$OWNER/$REPO/tags" | jq -r '.[0].name')
    else
        LATEST_TAG=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/tags" | jq -r '.[0].name')
    fi
fi

# Strip 'v' prefix for version
LATEST_VERSION="${LATEST_TAG#v}"

# Get current version
CURRENT_VERSION=$(grep -oP '(?<=version = ")[^"]*' default.nix)

echo "Current version: $CURRENT_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Already up to date!"
    exit 0
fi

echo "Updating from $CURRENT_VERSION to $LATEST_VERSION..."

# Prefetch new source hash
echo "Prefetching source..."
HASH_OUTPUT=$(nix-prefetch-github --rev "$LATEST_TAG" "$OWNER" "$REPO")
NEW_SRC_HASH=$(echo "$HASH_OUTPUT" | jq -r '.hash')
echo "New source hash: $NEW_SRC_HASH"

# Update version and source hash
sed -i "s|version = \"$CURRENT_VERSION\"|version = \"$LATEST_VERSION\"|" default.nix
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"$NEW_SRC_HASH\";|" default.nix

# Function to extract hash from nix build error
get_hash_from_build_error() {
    local attr="$1"
    local error_output
    
    # Set a fake hash first
    sed -i "s|$attr = \"sha256-[^\"]*\";|$attr = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\";|" default.nix
    
    # Try to build and capture the error
    error_output=$(nix-build "$REPO_ROOT" -A blink 2>&1 || true)
    
    # Extract the correct hash from error message
    local correct_hash
    correct_hash=$(echo "$error_output" | grep -oP "got:\s+\Ksha256-[^\s]+" | head -1)
    
    if [ -n "$correct_hash" ]; then
        echo "$correct_hash"
    else
        echo "ERROR: Could not extract hash for $attr" >&2
        return 1
    fi
}

# Update pnpmDeps hash
echo "Updating pnpmDeps hash (this may take a while)..."
PNPM_HASH=$(get_hash_from_build_error "hash")
if [ -n "$PNPM_HASH" ] && [ "$PNPM_HASH" != "ERROR"* ]; then
    # The first hash after src hash is pnpmDeps hash
    # We need to be more specific - update the one in pnpmDeps block
    sed -i "/pnpmDeps = fetchPnpmDeps/,/};/s|hash = \"sha256-[^\"]*\";|hash = \"$PNPM_HASH\";|" default.nix
    echo "New pnpmDeps hash: $PNPM_HASH"
fi

# Update cargoHash
echo "Updating cargoHash (this may take a while)..."
CARGO_HASH=$(get_hash_from_build_error "cargoHash")
if [ -n "$CARGO_HASH" ] && [ "$CARGO_HASH" != "ERROR"* ]; then
    sed -i "s|cargoHash = \"sha256-[^\"]*\";|cargoHash = \"$CARGO_HASH\";|" default.nix
    echo "New cargoHash: $CARGO_HASH"
fi

# Verify the build works
echo "Verifying build..."
if nix-build "$REPO_ROOT" -A blink --no-out-link; then
    echo "Build successful!"
else
    echo "Build failed! Manual intervention may be required."
    exit 1
fi

echo "Updated to version $LATEST_VERSION"

# Commit changes
if command -v git &> /dev/null && [ -d "$REPO_ROOT/.git" ]; then
    git add default.nix
    git commit -m "blink: $CURRENT_VERSION -> $LATEST_VERSION" || true
fi
