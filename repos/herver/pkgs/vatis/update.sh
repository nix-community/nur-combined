#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=vatis
nix_file="$dirname/default.nix"

latestVersion=$(curl -fsSL 'https://vatis.app/updates/linux/releases.linux.json' |
  jq -r '.Assets[] | select(.Type == "Full") | .Version' | sort -V | tail -n1)

if [ -z "$latestVersion" ]; then
  echo "$attr: failed to fetch latest version from the vATIS update feed" >&2
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
