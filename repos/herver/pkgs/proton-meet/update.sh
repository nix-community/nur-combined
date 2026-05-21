#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=proton-meet
nix_file="$dirname/default.nix"

version_json=$(curl -s 'https://proton.me/download/meet/linux/version.json')

# Get the latest stable release with rollout > 0
latestVersion=$(echo "$version_json" | jq -r '[.Releases[] | select(.CategoryName == "Stable" and .RolloutProportion > 0)][0].Version')
latestSha256=$(echo "$version_json" | jq -r '[.Releases[] | select(.CategoryName == "Stable" and .RolloutProportion > 0)][0].File[] | select(.Identifier | test("\\.deb")) | .Sha256CheckSum')

if [ -z "$latestVersion" ] || [ "$latestVersion" = "null" ]; then
  echo "$attr: failed to fetch latest version from version.json" >&2
  exit 1
fi

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

# Convert hex SHA256 to SRI format
sriHash=$(nix hash convert --hash-algo sha256 --to sri "sha256:$latestSha256")

# Update version and hash in default.nix
sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
