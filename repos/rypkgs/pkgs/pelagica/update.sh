#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-github git coreutils gnused nix

# shellcheck shell=bash
set -euo pipefail

cd "$(dirname "$0")"
REPO_ROOT=$(git rev-parse --show-toplevel)

OWNER="PelagicaApp"
REPO="pelagica"

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

# Upstream tags without a 'v' prefix, but strip one defensively in case that
# ever changes.
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

# Update version and source hash. The sed is scoped to the `src` block so it
# cannot clobber the pnpmDeps hash, which uses the same `hash = ` key.
sed -i "s|version = \"$CURRENT_VERSION\"|version = \"$LATEST_VERSION\"|" default.nix
sed -i "/src = fetchFromGitHub/,/};/s|hash = \"sha256-[^\"]*\";|hash = \"$NEW_SRC_HASH\";|" default.nix

FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# Rediscover one fixed-output hash by building only that derivation, so the
# build can report at most one mismatch and there is nothing to disambiguate.
rediscover_hash() {
    local attr="$1"

    local error_output
    error_output=$(nix-build "$REPO_ROOT" -A "$attr" --no-out-link 2>&1 || true)

    local correct_hash
    correct_hash=$(echo "$error_output" | grep -oP "got:\s+\Ksha256-[^\s]+" | head -1)

    if [ -z "$correct_hash" ]; then
        echo "ERROR: Could not extract hash for $attr" >&2
        echo "Build output:" >&2
        echo "$error_output" | tail -20 >&2
        return 1
    fi

    echo "$correct_hash"
}

# Update vendorHash (Go module dependencies)
echo "Updating vendorHash (this may take a while)..."
sed -i "s|vendorHash = \"sha256-[^\"]*\";|vendorHash = \"$FAKE_HASH\";|" default.nix
VENDOR_HASH=$(rediscover_hash pelagica.goModules)
sed -i "s|vendorHash = \"$FAKE_HASH\";|vendorHash = \"$VENDOR_HASH\";|" default.nix
echo "New vendorHash: $VENDOR_HASH"

# Update pnpmDeps hash (frontend dependencies)
echo "Updating pnpmDeps hash (this may take a while)..."
sed -i "/pnpmDeps = fetchPnpmDeps/,/};/s|hash = \"sha256-[^\"]*\";|hash = \"$FAKE_HASH\";|" default.nix
PNPM_HASH=$(rediscover_hash pelagica.pnpmDeps)
sed -i "/pnpmDeps = fetchPnpmDeps/,/};/s|hash = \"$FAKE_HASH\";|hash = \"$PNPM_HASH\";|" default.nix
echo "New pnpmDeps hash: $PNPM_HASH"

# Verify the build works
echo "Verifying build..."
if nix-build "$REPO_ROOT" -A pelagica --no-out-link; then
    echo "Build successful!"
else
    echo "Build failed! Manual intervention may be required."
    exit 1
fi

echo "Updated to version $LATEST_VERSION"

# Commit changes
if command -v git &> /dev/null && [ -d "$REPO_ROOT/.git" ]; then
    git add default.nix
    git commit -m "pelagica: $CURRENT_VERSION -> $LATEST_VERSION" || true
fi
