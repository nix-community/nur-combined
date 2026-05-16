#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
PACKAGE_NAME="tinyfish"
PACKAGE_DIR="$REPO_ROOT/pkgs/$PACKAGE_NAME"
PACKAGE_DEFAULT_NIX="$PACKAGE_DIR/default.nix"
PACKAGE_LOCKFILE="$PACKAGE_DIR/package-lock.json"

if [[ -z "$REPO_ROOT" ]]; then
  echo "error: expected to run inside the nurpkgs repository" >&2
  exit 1
fi
if [[ ! -f "$PACKAGE_DEFAULT_NIX" ]]; then
  echo "error: expected to run inside the nurpkgs repository" >&2
  exit 1
fi

VERSION="$(nix eval --raw .#tinyfish.version)"
if [[ -z "$VERSION" ]]; then
  echo "error: could not read tinyfish version from $PACKAGE_DEFAULT_NIX" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Generating package-lock.json for @tiny-fish/cli@$VERSION"

TGZ="$(npm pack --silent "@tiny-fish/cli@$VERSION" --pack-destination "$TMP")"
tar -xzf "$TMP/$TGZ" -C "$TMP"

pushd "$TMP/package" >/dev/null
npm install --package-lock-only --ignore-scripts --no-audit --no-fund
popd >/dev/null
cp "$TMP/package/package-lock.json" "$PACKAGE_LOCKFILE"

echo "Updated $PACKAGE_LOCKFILE"
