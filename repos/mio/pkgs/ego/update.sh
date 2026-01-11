#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-github nix coreutils gnused git

# shellcheck shell=bash
set -euo pipefail

cd "$(dirname "$0")"

OWNER="intgr"
REPO="ego"

if [ -n "${GITHUB_TOKEN:-}" ]; then
  TOKEN_ARGS=(--header "Authorization: token $GITHUB_TOKEN")
else
  TOKEN_ARGS=()
fi

DEFAULT_BRANCH=$(curl -s "${TOKEN_ARGS[@]}" "https://api.github.com/repos/$OWNER/$REPO" | jq -r '.default_branch')
if [ -z "$DEFAULT_BRANCH" ] || [ "$DEFAULT_BRANCH" = "null" ]; then
  DEFAULT_BRANCH=$(git ls-remote --symref "https://github.com/$OWNER/$REPO" HEAD | awk '/^ref:/ {print $2}' | sed 's|refs/heads/||')
fi
if [ -z "$DEFAULT_BRANCH" ] || [ "$DEFAULT_BRANCH" = "null" ]; then
  DEFAULT_BRANCH="master"
fi

LATEST_COMMIT=$(curl -s "${TOKEN_ARGS[@]}" "https://api.github.com/repos/$OWNER/$REPO/commits/$DEFAULT_BRANCH" | jq -r '.sha')
LATEST_DATE=""
VERSION_BASE=""

if [ -z "$LATEST_COMMIT" ] || [ "$LATEST_COMMIT" = "null" ]; then
  tmpdir=$(mktemp -d)
  git clone --depth 1 --branch "$DEFAULT_BRANCH" "https://github.com/$OWNER/$REPO" "$tmpdir" >/dev/null
  LATEST_COMMIT=$(git -C "$tmpdir" rev-parse HEAD)
  LATEST_DATE=$(git -C "$tmpdir" show -s --format=%cI HEAD)
  VERSION_BASE=$(rg -m1 '^version = "' "$tmpdir/Cargo.toml" | cut -d'"' -f2)
  rm -rf "$tmpdir"
else
  LATEST_DATE=$(curl -s "${TOKEN_ARGS[@]}" "https://api.github.com/repos/$OWNER/$REPO/commits/$LATEST_COMMIT" | jq -r '.commit.committer.date')
fi

if [ -z "$LATEST_COMMIT" ] || [ "$LATEST_COMMIT" = "null" ]; then
  echo "Failed to resolve latest commit for $OWNER/$REPO ($DEFAULT_BRANCH)."
  exit 1
fi

if [ -z "$LATEST_DATE" ] || [ "$LATEST_DATE" = "null" ]; then
  echo "Failed to resolve latest commit date for $LATEST_COMMIT."
  exit 1
fi
DATE_SHORT=$(echo "$LATEST_DATE" | cut -d'T' -f1 | tr -d '-')

CURRENT_COMMIT=$(rg -o 'rev = "[^"]+"' package.nix | cut -d'"' -f2)

if [ "$CURRENT_COMMIT" = "$LATEST_COMMIT" ]; then
  echo "Already up to date at commit $LATEST_COMMIT"
  exit 0
fi

if [ -z "$VERSION_BASE" ]; then
  VERSION_BASE=$(
    curl -s "${TOKEN_ARGS[@]}" "https://raw.githubusercontent.com/$OWNER/$REPO/$LATEST_COMMIT/Cargo.toml" \
      | rg -m1 '^version = "' \
      | cut -d'"' -f2
  )
fi

if [ -z "$VERSION_BASE" ]; then
  VERSION_BASE=$(rg -o 'version = "[^"]+"' package.nix | cut -d'"' -f2 | cut -d'-' -f1)
fi

VERSION="${VERSION_BASE}-unstable-${DATE_SHORT}"

HASH_OUTPUT=$(nix-prefetch-github --rev "$LATEST_COMMIT" "$OWNER" "$REPO")
NEW_HASH=$(echo "$HASH_OUTPUT" | jq -r '.hash')

sed -i "s|version = \".*\";|version = \"$VERSION\";|" package.nix
sed -i "s|rev = \".*\";|rev = \"$LATEST_COMMIT\";|" package.nix
sed -i "s|hash = \".*\";|hash = \"$NEW_HASH\";|" package.nix

sed -i "s|cargoHash = \".*\";|cargoHash = lib.fakeHash;|" package.nix

BUILD_LOG=$(nix-build -A ego --no-out-link 2>&1 || true)
NEW_CARGO_HASH=$(echo "$BUILD_LOG" | rg -o "got: sha256-[A-Za-z0-9+/=]+" | head -n1 | cut -d' ' -f2)

if [ -z "$NEW_CARGO_HASH" ]; then
  echo "Failed to determine cargoHash."
  exit 1
fi

sed -i "s|cargoHash = .*;|cargoHash = \"$NEW_CARGO_HASH\";|" package.nix

echo "Updated to version $VERSION"
echo "Commit: $LATEST_COMMIT"
echo "Hash: $NEW_HASH"
echo "cargoHash: $NEW_CARGO_HASH"

# Optionally commit changes
if command -v git &> /dev/null && [ -d "../../.git" ]; then
  git add package.nix
  git commit -m "ego: unstable-$(echo "$CURRENT_COMMIT" | cut -c1-9) -> unstable-$(echo "$LATEST_COMMIT" | cut -c1-9)" || true
fi
