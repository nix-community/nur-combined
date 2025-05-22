#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnused jq github-cli nix-prefetch

set -x -eu -o pipefail

cd $(dirname "${BASH_SOURCE[0]}")

setKV () {
    sed -i "s|$1 = .*;|$1 = ${2:-};|" ./package.nix
}

RELEASES_JSON="$(gh api repos/awnion/custom-iosevka-nerd-font/releases)"
LATEST_JSON=$(jq 'map(select(.draft | not)) | .[0]' <<< "$RELEASES_JSON") # allow prereleases

LATEST_IS_RC="$(jq -r .prerelease <<< "$LATEST_JSON")"
LATEST_TAG="$(jq -r .tag_name <<< "$LATEST_JSON")"
LATEST_ZIP="$(jq -r '.assets.[0].browser_download_url' <<< "$LATEST_JSON")"

if [ "$LATEST_IS_RC" = "true" ]; then
    LATEST_VERSION="$(sed -Ee "s|v([0-9]+\.[0-9]+\.[0-9]+)-rc|\1|" <<< "$LATEST_TAG")"
else
    LATEST_VERSION="$LATEST_TAG" 
fi

SRC_HASH=$(nix-prefetch-url --quiet --unpack "$LATEST_ZIP")
SRC_HASH=$(nix hash convert --hash-algo sha256 --to sri "$SRC_HASH")

setKV version "\"$LATEST_VERSION\""
setKV hash "\"$SRC_HASH\""
setKV isRc "$LATEST_IS_RC"
