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

for system in $(jq -r 'keys[] | select(. != "version")' "$JSON_FILE"); do
  name=$(jq -r --arg system "$system" '.[$system].name' "$JSON_FILE")
  codehost_name=$(jq -r --arg system "$system" \
    '.[$system] | .codehost.name // (.name | sub("^codex-"; "codex-code-mode-host-"))' "$JSON_FILE")

  for component in codex codehost; do
    if [[ "$component" == "codex" ]]; then
      asset_name="$name"
      path=$(jq -cn --arg system "$system" '[$system]')
    else
      asset_name="$codehost_name"
      path=$(jq -cn --arg system "$system" '[$system, "codehost"]')
    fi
    url="https://github.com/$OWNER/$REPO/releases/download/$TAG/$asset_name.zst"

    echo "Prefetching $system ($component) ..."
    echo "  url: $url"

    hash=$(nix store prefetch-file "$url" --json | jq -er .hash)

    echo "  hash: $hash"
    jq --argjson path "$path" --arg name "$asset_name" --arg hash "$hash" \
      'setpath($path + ["name"]; $name) | setpath($path + ["hash"]; $hash)' "$TMP" > "$TMP.next"
    mv "$TMP.next" "$TMP"
  done
done

mv "$TMP" "$JSON_FILE"
echo "Updated $JSON_FILE"
