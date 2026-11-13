#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#jq --command bash
set -euo pipefail

# Usage: ./update.sh [ref], defaulting to the main branch.
PACKAGE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_FILE="$PACKAGE_DIR/source.json"
REF=${1:-main}
if (( $# > 1 )) || [[ -z "$REF" || "$REF" == -* ]]; then
  echo "Usage: $0 [ref]" >&2
  exit 1
fi

OWNER=$(jq -er .owner "$SOURCE_FILE")
REPO=$(jq -er .repo "$SOURCE_FILE")
TMP=$(mktemp "${SOURCE_FILE}.tmp.XXXXXX")
trap 'rm -f "$TMP"' EXIT

# Refresh mutable refs and record the resolved commit, just as flake update did.
SOURCE=$(nix flake prefetch --refresh --json "github:$OWNER/$REPO/$REF")
REV=$(jq -er .locked.rev <<< "$SOURCE")
HASH=$(jq -er .hash <<< "$SOURCE")
jq --arg rev "$REV" --arg hash "$HASH" \
  '.rev = $rev | .narHash = $hash' "$SOURCE_FILE" > "$TMP"
mv "$TMP" "$SOURCE_FILE"
echo "Updated rime-ice to $REV"
