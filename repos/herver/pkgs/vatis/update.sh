#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=vatis
nix_file="$dirname/default.nix"

# Get latest release tag from GitHub (including pre-releases)
latestVersion=$(curl -s 'https://api.github.com/repos/vatis-project/vatis/releases?per_page=1' | jq -r '.[0].tag_name' | sed 's/^v//')

if [ -z "$latestVersion" ] || [ "$latestVersion" = "null" ]; then
  echo "$attr: failed to fetch latest version from GitHub" >&2
  exit 1
fi

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

# Download AppImage and compute hash
url="https://hub.vatis.app/download/linux"
{
  read hash
  read storePath
} < <(nix-prefetch-url "$url" --type sha256 --print-path --name "vATIS-${latestVersion}.AppImage")

sriHash=$(nix hash convert --hash-algo sha256 --to sri "$hash")

# Update version and hash in default.nix
sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
