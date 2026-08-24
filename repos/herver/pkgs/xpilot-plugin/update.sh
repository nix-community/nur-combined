#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=xpilot-plugin
nix_file="$dirname/default.nix"

# Query the download manifest for the latest stable release.
manifest=$(curl -fsSL 'https://downloads.xpilot.app')

latestVersion=$(echo "$manifest" | jq -r '.stable.version')
url=$(echo "$manifest" | jq -r '.stable.pluginPackage.linux')

if [ -z "$latestVersion" ] || [ "$latestVersion" = "null" ]; then
  echo "$attr: failed to fetch latest version" >&2
  exit 1
fi

if [ -z "$url" ] || [ "$url" = "null" ]; then
  echo "$attr: failed to fetch plugin download URL" >&2
  exit 1
fi

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

# Download plugin archive and compute hash
hash=$(nix-prefetch-url "$url" --type sha256 --name "xpilot-plugin-${latestVersion}.zip")
sriHash=$(nix hash convert --hash-algo sha256 --to sri "$hash")

# Update version, url, hash, and src name in default.nix
sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|url = \".*Plugin-linux\.zip\";|url = \"$url\";|" \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -e "s|name = \"xpilot-plugin-.*\.zip\";|name = \"xpilot-plugin-${latestVersion}.zip\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
