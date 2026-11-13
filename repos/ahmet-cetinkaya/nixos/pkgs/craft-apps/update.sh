#!/usr/bin/env bash
# Update every Craft app pin from upstream releases.
# Reads each release's SHA256SUMS.txt so pinned hashes match the published
# ones byte for byte. Run from anywhere; edits <app>/sources.nix in place.
set -euo pipefail

cd "$(dirname "$0")"

APPS="photocraft lightcraft filmcraft designcraft vectorcraft pdfcraft effectcraft wordcraft deckcraft gridcraft cadcraft soundcraft"

for app in $APPS; do
  current=$(grep 'version = "' "$app/sources.nix" | sed 's/.*version = "\(.*\)".*/\1/')
  tag=$(curl -sSL "https://api.github.com/repos/storytold/$app/releases/latest" | jq -r '.tag_name')
  latest=${tag#v}

  if [ -z "$latest" ] || [ "$latest" = "null" ]; then
    echo "❌ $app: could not resolve latest release tag" >&2
    exit 1
  fi

  if [ "$current" = "$latest" ]; then
    echo "✅ $app: $current (up to date)"
    continue
  fi

  sums=$(curl -sSL "https://github.com/storytold/$app/releases/download/$tag/SHA256SUMS.txt")
  sha_x86=$(echo "$sums" | awk '$2 ~ /linux-x86_64\.tar\.gz$/ {print $1}' | head -1)
  sha_aarch64=$(echo "$sums" | awk '$2 ~ /linux-aarch64\.tar\.gz$/ {print $1}' | head -1)

  if [ -z "$sha_x86" ] || [ -z "$sha_aarch64" ]; then
    echo "❌ $app: SHA256SUMS.txt missing linux tarball hashes" >&2
    exit 1
  fi

  cat > "$app/sources.nix" <<EOF
{
  version = "$latest";
  x86_64-linux = "$sha_x86";
  aarch64-linux = "$sha_aarch64";
}
EOF
  echo "⬆️  $app: $current -> $latest"
done
