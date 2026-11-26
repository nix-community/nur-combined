#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#gh nixpkgs#jq --command bash
set -euo pipefail

OWNER="openai"
REPO="codex"
JSON_FILE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/versions.json"
TAG=${1:-}
if (( $# > 1 )) || [[ $# == 1 && -z "$TAG" ]]; then
  echo "Usage: $0 [tag]" >&2
  exit 1
fi

if [[ -z "$TAG" ]]; then
  echo "Fetching latest release for $OWNER/$REPO ..."
  TAG=$(gh api "repos/$OWNER/$REPO/releases/latest" --jq .tag_name)
fi
VERSION=${TAG#rust-v}

if [[ ! "$TAG" =~ ^rust-v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Unexpected release tag: $TAG" >&2
  exit 1
fi

echo "Got:"
echo "  tag:     $TAG"
echo "  version: $VERSION"

TMP=$(mktemp "${JSON_FILE}.tmp.XXXXXX")
trap 'rm -f "$TMP" "$TMP.next"' EXIT

jq --arg version "$VERSION" '.version = $version' "$JSON_FILE" > "$TMP"

platforms=$(jq -er 'del(.version) | to_entries[] | [.key, .value.target] | @tsv' "$JSON_FILE")
while IFS=$'\t' read -r system target; do
  url="https://github.com/$OWNER/$REPO/releases/download/$TAG/codex-package-$target.tar.zst"

  echo "Prefetching $system ..."
  echo "  url: $url"
  hash=$(nix store prefetch-file "$url" --json | jq -er .hash)
  echo "  hash: $hash"

  jq --arg system "$system" --arg hash "$hash" '.[$system].hash = $hash' "$TMP" > "$TMP.next"
  mv "$TMP.next" "$TMP"
done <<< "$platforms"

mv "$TMP" "$JSON_FILE"
echo "Updated $JSON_FILE"
