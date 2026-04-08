#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash common-updater-scripts html-xml-utils curl

set -euo pipefail

attr() {
  nix-instantiate --eval -A renpy_7.$1 | tr -d '"'
}

old_version="$(attr version)"

header=$(mktemp)
new_version=""
trap 'rm -f "$header"' EXIT

url="https://api.github.com/repos/renpy/renpy/releases"
while [[ -n "$url" ]]; do
  body="$(curl -sSL -D "$header" "$url")"
  new_version=$(echo "$body" | jq -r '.[] | .tag_name | select(startswith("7"))' | head -n 1)
  if [[ -n "$new_version" ]] && [[ "$new_version" != "null" ]]; then
    break
  fi
  url=$(grep -i '^link:' "$header" | sed -n 's/.*<\([^>]*\)>; rel="next".*/\1/p')
done

if [[ -n "$new_version" ]] && [[ "$new_version" != "null" ]]; then
  echo "Latest version: $new_version" >&2
else
  echo "Cannot find the latest version" >&2
  exit 1
fi

if [[ "$old_version" == "$new_version" ]]; then
  echo "Already up to date" >&2
  exit 0
fi

nix_file="$(attr meta.position | cut -d: -f1)"

codename="$(curl -L https://renpy.org/latest-7.html | hxclean | hxselect -c h1 small)"
sed -E -i "s/(version_name = ).*/\1$codename/" "$nix_file"

old_bin_src_hash="$(attr binSrc.hash)"
new_bin_src_hash="$(nix-hash --type sha256 --to-sri "$(nix-prefetch-url --unpack "$(attr binSrc.url)")")"
sed -i "s|$old_bin_src_hash|$new_bin_src_hash|" "$nix_file"

old_bin_src_arm_hash="$(attr binSrcArm.hash)"
new_bin_src_arm_hash="$(nix-hash --type sha256 --to-sri "$(nix-prefetch-url --unpack "$(attr binSrcArm.url)")")"
sed -i "s|$old_bin_src_arm_hash|$new_bin_src_arm_hash|" "$nix_file"

update-source-version renpy_7 $new_version
