#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=stratos
nix_file="$dirname/default.nix"
base_url='https://cdn.skyvexsoftware.com/stratos/release'

# electron-updater metadata: carries version and base64 sha512 of each AppImage
manifest_x64=$(curl -sfL "$base_url/latest-linux.yml")
manifest_arm64=$(curl -sfL "$base_url/latest-linux-arm64.yml")

latestVersion=$(sed -n 's/^version: *//p' <<<"$manifest_x64")
armVersion=$(sed -n 's/^version: *//p' <<<"$manifest_arm64")
sha512_x64=$(sed -n 's/^sha512: *//p' <<<"$manifest_x64")
sha512_arm64=$(sed -n 's/^sha512: *//p' <<<"$manifest_arm64")

if [ -z "$latestVersion" ] || [ -z "$sha512_x64" ] || [ -z "$sha512_arm64" ]; then
  echo "$attr: failed to parse latest-linux*.yml" >&2
  exit 1
fi

if [ "$latestVersion" != "$armVersion" ]; then
  echo "$attr: x86_64 ($latestVersion) and arm64 ($armVersion) versions differ, skipping" >&2
  exit 1
fi

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

# Hashes are rewritten per platform block: the line following `arch = "..."`.
sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "/arch = \"x86_64\";/{n;s|hash = \"sha512-[a-zA-Z0-9/+=]+\";|hash = \"sha512-$sha512_x64\";|}" \
  -e "/arch = \"arm64\";/{n;s|hash = \"sha512-[a-zA-Z0-9/+=]+\";|hash = \"sha512-$sha512_arm64\";|}" \
  -i "$nix_file"

echo "Updated $nix_file"
