#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=claude-code
nix_file="$dirname/default.nix"

base="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
platform="linux-x64"

# Track the "latest" channel (use "stable" instead for the conservative pointer)
latestVersion=$(curl -fsSL "$base/latest")

if [ -z "$latestVersion" ]; then
  echo "$attr: failed to fetch latest version" >&2
  exit 1
fi

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

# The manifest publishes the SHA256 per platform, so no need to download the binary.
checksum=$(curl -fsSL "$base/$latestVersion/manifest.json" \
  | jq -r ".platforms[\"$platform\"].checksum")

if [ -z "$checksum" ] || [ "$checksum" = "null" ]; then
  echo "$attr: no checksum for $platform in manifest" >&2
  exit 1
fi

sriHash=$(nix hash convert --hash-algo sha256 --to sri "sha256:$checksum")

sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
