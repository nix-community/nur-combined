#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#gh nixpkgs#jq --command bash
set -euo pipefail

# Usage: ./update.sh [tag], defaulting to the latest stable GitHub release.
PACKAGE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$PACKAGE_DIR/../.." && pwd -P)"
SOURCE_FILE="$PACKAGE_DIR/source.json"
TAG=${1:-}
if (( $# > 1 )) || [[ $# == 1 && -z "$TAG" ]]; then
  echo "Usage: $0 [tag]" >&2
  exit 1
fi

OWNER=$(jq -er .owner "$SOURCE_FILE")
REPO=$(jq -er .repo "$SOURCE_FILE")
if [[ -z "$TAG" ]]; then
  TAG=$(gh api "repos/$OWNER/$REPO/releases/latest" --jq .tag_name)
fi
if [[ ! "$TAG" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Expected a stable version tag (for example, v0.3.0), got: $TAG" >&2
  exit 1
fi
VERSION=${TAG#v}

TMP=$(mktemp "${SOURCE_FILE}.tmp.XXXXXX")
trap 'rm -f "$TMP" "$TMP.log"' EXIT
SOURCE=$(nix flake prefetch --refresh --json "github:$OWNER/$REPO/$TAG")
REV=$(jq -er .locked.rev <<< "$SOURCE")
HASH=$(jq -er .hash <<< "$SOURCE")
SOURCE_PATH=$(jq -er .storePath <<< "$SOURCE")

# Use this repository's pinned Go builder, including its vendoring hooks.
NIXPKGS=$(nix flake archive --json --no-write-lock-file "path:$REPO_ROOT" \
  | jq -er .inputs.nixpkgs.path)
DRV=$(nix-instantiate --expr '
  { nixpkgs, packageDir, sourcePath, version }:
  let pkgs = import (builtins.toPath nixpkgs) { config = {}; overlays = []; }; in
  ((pkgs.callPackage (builtins.toPath packageDir) { }).overrideAttrs {
    inherit version;
    src = builtins.storePath sourcePath;
    vendorHash = pkgs.lib.fakeHash;
  }).goModules
' --argstr nixpkgs "$NIXPKGS" --argstr packageDir "$PACKAGE_DIR" \
  --argstr sourcePath "$SOURCE_PATH" \
  --argstr version "$VERSION")
# A deliberate hash mismatch reveals the hash produced by buildGoModule.
# Only accept a mismatch from this exact derivation; other build errors abort.
if nix build --no-link "$DRV^*" 2> "$TMP.log"; then
  echo "Expected a vendor hash mismatch, but the placeholder hash succeeded" >&2
  exit 1
fi
LOG=$(< "$TMP.log")
MISMATCH="hash mismatch in fixed-output derivation '$DRV'"
if [[ "$LOG" != *"$MISMATCH"* ]]; then
  cat "$TMP.log" >&2
  exit 1
fi
LOG=${LOG#*"$MISMATCH"}
if [[ "$LOG" =~ got:[[:space:]]+(sha256-[A-Za-z0-9+/]{43}=) ]]; then
  VENDOR_HASH=${BASH_REMATCH[1]}
else
  cat "$TMP.log" >&2
  exit 1
fi

# Keep the revision, version and both hashes together; write only after success.
jq --arg version "$VERSION" --arg rev "$REV" --arg hash "$HASH" \
  --arg vendorHash "$VENDOR_HASH" \
  '.version = $version | .rev = $rev | .narHash = $hash | .vendorHash = $vendorHash' \
  "$SOURCE_FILE" > "$TMP"
mv "$TMP" "$SOURCE_FILE"
echo "Updated portop to $VERSION ($REV)"
