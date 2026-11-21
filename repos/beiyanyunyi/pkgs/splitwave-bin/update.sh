#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#gh nixpkgs#jq --command bash
set -euo pipefail

manifest="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/versions.json"
tag=${1:-}
if (( $# > 1 )) || [[ $# == 1 && -z "$tag" ]]; then
  echo "Usage: $0 [tag]" >&2
  exit 1
fi
if [[ -n "$tag" && ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Expected a stable Splitwave tag (for example, v1.5.0), got: $tag" >&2
  exit 1
fi

release_ref=latest
if [[ -n "$tag" ]]; then
  release_ref="tags/$tag"
fi
release=$(gh api "repos/Horuse/Splitwave/releases/$release_ref")
tag=$(jq -er 'select(.draft == false and .prerelease == false) | .tag_name' <<< "$release")
if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Unexpected tag for a stable Splitwave release: $tag" >&2
  exit 1
fi

url=$(jq -er '
  [.assets[] | select(.name | endswith("_amd64.deb"))]
  | if length == 1 then .[0].browser_download_url
    else error("Expected exactly one amd64 Debian asset") end
' <<< "$release")
hash=$(nix store prefetch-file "$url" --json | jq -er .hash)

tmp=$(mktemp "${manifest}.tmp.XXXXXX")
trap 'rm -f "$tmp"' EXIT
jq -n --arg version "${tag#v}" --arg url "$url" --arg hash "$hash" \
  '{version: $version, url: $url, hash: $hash}' > "$tmp"
mv "$tmp" "$manifest"
echo "Updated splitwave-bin to $tag ($hash)"
