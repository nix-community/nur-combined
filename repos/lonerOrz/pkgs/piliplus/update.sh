#!/usr/bin/env bash
# Discover the real uploaded AppImage asset name (its CI build number changes
# every release and isn't in the tag) + SRI hash, then rewrite version.json.
set -euo pipefail

owner="bggRGjQaUbCoE"
repo="PiliPlus"
pname="piliplus"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
version_file="$script_dir/version.json"
helper_dir="$script_dir/../../.github/script"

echo ">> [1/4] Fetching latest release tag..."
latest_tag=$("$helper_dir/github-tag-fetch.sh" "$owner/$repo")
if [[ -z "$latest_tag" || "$latest_tag" == "null" ]]; then
  echo "Failed to fetch latest tag." >&2
  exit 1
fi

current_version=$(jq -r '.version' "$version_file" 2>/dev/null || echo "")
if [[ "$latest_tag" == "$current_version" ]]; then
  echo "OK: $pname is already at $current_version."
  exit 0
fi

echo "OK: $current_version -> $latest_tag"

release_url="https://api.github.com/repos/$owner/$repo/releases/tags/$latest_tag"

echo ">> [2/4] Discovering the AppImage asset name..."
# CI build number is unpredictable; read the real amd64 asset name from the release.
asset_name=$(curl -sS -L --fail --retry 3 \
  "${GITHUB_TOKEN:+-H}" "Authorization: Bearer $GITHUB_TOKEN" \
  "$release_url" \
  | jq -r '.assets[].name | select(test("linux_.*_amd64\\.AppImage$")) | first')

if [[ -z "$asset_name" ]]; then
  echo "ERROR: could not find an amd64 AppImage asset for $latest_tag" >&2
  exit 1
fi
echo "OK: asset = $asset_name"

asset_url="https://github.com/$owner/$repo/releases/download/$latest_tag/$asset_name"

echo ">> [3/4] Prefetching SRI hash for $asset_url ..."
# There is no aarch64 AppImage for piliplus, so only x86_64-linux is tracked.
new_hash=$(nix-prefetch-url --type sha256 "$asset_url" | xargs nix-hash --to-sri --type sha256)
if [[ -z "$new_hash" ]]; then
  echo "ERROR: failed to prefetch hash for $asset_url" >&2
  exit 1
fi
echo "OK: hash = $new_hash"

echo ">> [4/4] Writing $version_file ..."
tmp=$(mktemp)
jq --arg v "$latest_tag" --arg a "$asset_name" --arg h "$new_hash" \
  '.version = $v | .asset-name = $a | ."x86_64-linux-hash" = $h' \
  "$version_file" > "$tmp" && mv "$tmp" "$version_file"

echo "Done: $pname updated to $latest_tag ($asset_name)."
