#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=skunkcrafts-updater
nix_file="$dirname/default.nix"
depot="https://1228098873.rsc.cdn77.org/updater/depot"

# The app's own update check: the depot cfg announces the published version as "version|X.Y.Z".
# The t= query bypasses stale CDN copies, as the app does.
latestVersion=$(curl -sfL "$depot/skunkcrafts_updater.cfg?t=$(date +%s)" | tr -d '\r' | sed -n 's/^version|//p')

if [ -z "$latestVersion" ]; then
  echo "$attr: failed to read the version from skunkcrafts_updater.cfg" >&2
  exit 1
fi

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

hash=$(nix-prefetch-url --type sha256 "$depot/SkunkcraftsUpdater-${latestVersion}-x86_64.AppImage")
sriHash=$(nix hash convert --hash-algo sha256 --to sri "$hash")

sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
