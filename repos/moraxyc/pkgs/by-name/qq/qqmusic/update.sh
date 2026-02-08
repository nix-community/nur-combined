#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix perl moreutils

PKG_DIR="$(realpath "$(dirname "$0")")"
SOURCES_FILE="$PKG_DIR/sources.json"

MATCH_DATA=$(curl -sL "https://y.qq.com/download/download.js" | perl -ne '
while (/QQMusicMac[._-]?v?(\d+(?:[._]\d+)+)[._-]?build[._-]?(\d+)\.dmg[^"'\'' ]*?[?&]sign=([^&"'\'' ]+)/ig) {
    print "$1,$2,$3\n";
}
' | head -n 1)
IFS=, read -r VERSION BUILD SIGN <<< "$MATCH_DATA"

if [[ "$UPDATE_NIX_OLD_VERSION" == "$VERSION" ]]; then
  echo "Already up to date!"
  exit 0
fi

DOWNLOAD_URL="https://c.y.qq.com/cgi-bin/file_redirect.fcg?bid=dldir&file=ecosfile%2Fmusic_clntupate%2Fmac%2Fother%2FQQMusicMac${VERSION}Build${BUILD}.dmg&sign=${SIGN}"

NEW_HASH=$(nix-prefetch-url --type sha256 "$DOWNLOAD_URL" --name "QQMusicMac${VERSION}Build${BUILD}.dmg")
SRI_HASH=$(nix --extra-experimental-features nix-command hash to-sri --type sha256 "$NEW_HASH")

for PLATFORM in "aarch64-darwin" "x86_64-darwin"; do
  jq --arg version "$VERSION" \
     --arg sign "$SIGN" \
     --arg build "$BUILD" \
     --arg hash "$SRI_HASH" \
     '.[$platform] = {version: $version, sign: $sign, build: $build, hash: $hash}' \
     --arg platform "$PLATFORM" \
     "$SOURCES_FILE" | sponge "$SOURCES_FILE"
done
