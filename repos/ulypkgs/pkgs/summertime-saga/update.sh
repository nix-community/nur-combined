#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl pup megacmd playwright-scrape

set -euo pipefail

attr() {
  nix-instantiate --eval -A summertime-saga.$1 | tr -d '"'
}

webpage="$(playwright-scrape https://summertimesaga.com/download)"
file_id="$(echo "$webpage" | pup 'h4:contains("Linux") + p > a:contains("mega") attr{href}' | head -n1 | sed 's|https://mega\.nz/#||')"
if [[ "$file_id" == "$(attr src.fileId)" ]]; then
  echo "Already up to date." >&2
  exit 0
fi

version="$(echo "$webpage" | sed -nE 's|.*<h1>Download v?([0-9]+\.[0-9]+\.[0-9]+).*|\1|p' | head -n1)"
nix_file="$(attr meta.position | cut -d: -f1)"
sed -i "s|version = \"[^\"]*\";|version = \"$version\";|" "$nix_file"
sed -i "s|fileId = \"[^\"]*\";|fileId = \"$file_id\";|" "$nix_file"

echo "$version" "$file_id"
exit

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

if [[ -n "$MEGA_EMAIL" && -n "$MEGA_PASSWORD" ]]; then
  mega-login "$MEGA_EMAIL" "$MEGA_PASSWORD"
fi
download="$tmpdir/$(attr src.name)"
mega-get "https://mega.nz/#$file_id" "$download"
sed -i "s|hash = \".*\";|hash = \"$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url "file://$download)")\";|" "$nix_file"
