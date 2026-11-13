#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#jq --command bash
set -euo pipefail

# Usage: ./update.sh [ref], defaulting to the master branch.
PACKAGE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_FILE="$PACKAGE_DIR/source.json"
REF=${1:-master}
if (( $# > 1 )) || [[ -z "$REF" || "$REF" == -* ]]; then
  echo "Usage: $0 [ref]" >&2
  exit 1
fi

OWNER=$(jq -er .owner "$SOURCE_FILE")
REPO=$(jq -er .repo "$SOURCE_FILE")
TMP=$(mktemp "${SOURCE_FILE}.tmp.XXXXXX")
trap 'rm -f "$TMP"' EXIT
SOURCE=$(nix flake prefetch --refresh --json "github:$OWNER/$REPO/$REF")
REV=$(jq -er .locked.rev <<< "$SOURCE")
HASH=$(jq -er .hash <<< "$SOURCE")
SOURCE_PATH=$(jq -er .storePath <<< "$SOURCE")
DATE=$(jq -er '.locked.lastModified | strftime("%Y-%m-%d")' <<< "$SOURCE")
BASE_VERSION=$(< "$SOURCE_PATH/version")
if [[ ! "$BASE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Unexpected patchelf version: $BASE_VERSION" >&2
  exit 1
fi
VERSION="$BASE_VERSION-unstable-$DATE"

jq --arg version "$VERSION" --arg rev "$REV" --arg hash "$HASH" \
  '.version = $version | .rev = $rev | .narHash = $hash' "$SOURCE_FILE" > "$TMP"
mv "$TMP" "$SOURCE_FILE"
echo "Updated patchelf-unstable to $VERSION ($REV)"
