#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
nixpkgs=$(realpath "${dirname}/../..")
attr=ibkr-desktop
nix_file="$dirname/default.nix"

url="https://download2.interactivebrokers.com/installers/ntws/latest-standalone/ntws-latest-standalone-linux-x64.sh"
latestEtagHash=$(curl -sI "$url" | grep -i ETag | sed -E 's/.*"([^:]+):.*/\1/')

currentEtagHash=$(nix-instantiate --eval -E "with import $nixpkgs {}; $attr.etagHash" | tr -d '"')
currentVersion=$(nix-instantiate --eval -E "with import $nixpkgs {}; $attr.version" | tr -d '"')

if [ "$currentEtagHash" = "$latestEtagHash" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: ETag changed, checking for new version..."

# Download installer and get hash + store path
{
  read hash
  read installScriptPath
} < <(nix-prefetch-url "$url" --type sha256 --print-path)

sriHash=$(nix hash convert --hash-algo sha256 --to sri "$hash")

# Extract installer to read the version from i4jparams.conf
src=$(mktemp -d /tmp/ibkr-desktop-src.XXX)
pushd "$src" > /dev/null

INSTALL4J_TEMP="$src" sh "$installScriptPath" __i4j_extract_and_exit
latestVersion=$(grep buildInfo "$src/"*.dir/i4jparams.conf | sed -E 's/.*name="buildInfo" value="Build (\S+) .*/\1/')

popd > /dev/null
rm -rf "$src"

if [ "$latestVersion" = "$currentVersion" ]; then
  echo "$attr: version unchanged ($currentVersion) but binary updated, updating hash and ETag"
else
  echo "$attr: $currentVersion -> $latestVersion"
fi

# Update hash, version, and etagHash in default.nix
sed -E \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|etagHash = \"$currentEtagHash\";|etagHash = \"$latestEtagHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"
