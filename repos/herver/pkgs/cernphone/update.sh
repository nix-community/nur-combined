#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=cernphone
nix_file="$dirname/default.nix"

# electron-updater metadata: carries version and base64 sha512 of the AppImage
manifest=$(curl -sfL 'https://cernphone-sw.web.cern.ch/cernphone-sw/releases/latest-linux.yml')
latestVersion=$(sed -n 's/^version: *//p' <<<"$manifest")
sha512=$(sed -n 's/^sha512: *//p' <<<"$manifest")

if [ -z "$latestVersion" ] || [ -z "$sha512" ]; then
  echo "$attr: failed to parse latest-linux.yml" >&2
  exit 1
fi

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|hash = \"sha512-[a-zA-Z0-9/+=]+\";|hash = \"sha512-$sha512\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
