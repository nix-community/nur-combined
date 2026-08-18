#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=trackaudio
nix_file="$dirname/default.nix"

# Track the newest published release.
# /releases/latest is unreliable here (betas are flagged prerelease=false), so
# take the first entry of the release list (GitHub returns them newest-first).
latestVersion=$(curl -s 'https://api.github.com/repos/pierr3/TrackAudio/releases?per_page=100' \
  | jq -r '[.[] | select(.draft==false)][0].tag_name' \
  | sed 's/^v//')

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

# Download the .deb asset and compute its SRI hash.
url="https://github.com/pierr3/TrackAudio/releases/download/${latestVersion}/trackaudio_${latestVersion}_amd64.deb"
hash=$(nix-prefetch-url "$url" --type sha256)
sriHash=$(nix hash convert --hash-algo sha256 --to sri "$hash")

# Update version and hash in default.nix
sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
