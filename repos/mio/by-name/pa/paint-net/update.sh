#!/usr/bin/env bash
# Paint.NET publishes stable GitHub releases and also keeps beta tags that
# sort above the stable version. Use the releases API, and refresh the nested
# portable-zip hash that nix-update cannot see through this src derivation.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
package=by-name/pa/paint-net/package.nix

current_version=$(sed -nE 's/^  version = "([^"]+)";/\1/p' "$package" | head -n 1)
if [ -z "$current_version" ]; then
  echo "update-paint-net: no version in $package" >&2
  exit 1
fi

tag=$(curl -fsSL --retry 3 "https://api.github.com/repos/paintdotnet/release/releases?per_page=100" |
  jq -r 'map(select((.draft | not) and (.prerelease | not))) | .[0].tag_name // empty')
if [ -z "$tag" ]; then
  echo "update-paint-net: no stable release found" >&2
  exit 1
fi
version=${tag#v}

echo "Current version: $current_version"
echo "Target version:  $version"
if [ "$current_version" = "$version" ]; then
  echo "paint-net is already up to date ($version)."
  exit 0
fi

url="https://github.com/paintdotnet/release/releases/download/v$version/paint.net.$version.portable.x64.zip"
raw_hash=$(nix-prefetch-url "$url" | tail -n 1)
new_hash=$(nix hash convert --hash-algo sha256 --to sri "$raw_hash")

old_hash=$(sed -nE 's/^      hash = "([^"]+)";/\1/p' "$package" | head -n 1)
if [ -z "$old_hash" ]; then
  echo "update-paint-net: no source hash in $package" >&2
  exit 1
fi
sed -i "s/^  version = \"$current_version\";/  version = \"$version\";/" "$package"
sed -i "s|^      hash = \"$old_hash\";|      hash = \"$new_hash\";|" "$package"

nixfmt "$package"
echo "Successfully updated paint-net to $version ($new_hash)"
