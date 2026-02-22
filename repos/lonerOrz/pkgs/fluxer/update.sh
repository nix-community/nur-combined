#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnugrep gnused coreutils nix

set -euo pipefail

cd "$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"

pname="fluxer"
package_file="./default.nix"

echo "Checking latest version..."

latest_version=$(
  curl -sL "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage" -I 2>/dev/null \
  | grep -i "^location:" | head -n1 \
  | sed -n 's/.*fluxer-stable-\([0-9.]*\)-x86_64\.AppImage.*/\1/p'
)

if [ -z "$latest_version" ]; then
  echo "Failed to fetch version from API"
  exit 1
fi

echo "Latest version: $latest_version"

current_version=$(grep -oP '^\s*version\s*=\s*"\K[0-9.]+' "$package_file")
echo "Current version in default.nix: $current_version"

if [ "$latest_version" = "$current_version" ]; then
    echo "Package is already at the latest version. Nothing to do."
    exit 0
fi

echo "Update needed: $current_version -> $latest_version"

WORKDIR="$(mktemp -d)"
TMP_NIX="$WORKDIR/default.nix"
trap 'rc=$?; echo "Error occurred, cleaning $WORKDIR"; rm -rf "$WORKDIR"; exit $rc' ERR INT

cp "$package_file" "$TMP_NIX"

sed -i -E 's|(version\s*=\s*")[0-9.]+(")|\1'"$latest_version"'\2|' "$TMP_NIX"

x86_url="https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/appimage"
arm64_url="https://api.fluxer.app/dl/desktop/stable/linux/arm64/latest/appimage"

echo "Getting hash for x86_64-linux..."
x86_hash=$(nix-prefetch-url --type sha256 "$x86_url")
x86_hash=$(nix hash to-base64 "sha256:$x86_hash")
x86_hash="sha256-$x86_hash"
echo "x86_64 hash: $x86_hash"

echo "Getting hash for aarch64-linux..."
if arm64_hash=$(nix-prefetch-url --type sha256 "$arm64_url" 2>/dev/null); then
  arm64_hash=$(nix hash to-base64 "sha256:$arm64_hash")
  arm64_hash="sha256-$arm64_hash"
  echo "aarch64 hash: $arm64_hash"
else
  echo "Failed to get aarch64 hash, keeping placeholder"
  arm64_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
fi

echo "Replacing x86_64 hash"
sed -i -zE 's|(x86_64-linux = fetchurl \{[^}]*hash = ")[^"]*(";)|\1'"$x86_hash"'\2|' "$TMP_NIX"

echo "Replacing aarch64 hash"
sed -i -zE 's|(aarch64-linux = fetchurl \{[^}]*hash = ")[^"]*(";)|\1'"$arm64_hash"'\2|' "$TMP_NIX"

mv "$TMP_NIX" "$package_file"
rm -rf "$WORKDIR"
trap - ERR INT

echo "Update completed successfully!"
echo "Package is now at version $latest_version."
