#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnused jq curl nurl

set -x -eu -o pipefail

cd $(dirname "${BASH_SOURCE[0]}")

setKV () {
    sed -i "s|$1 = .*;|$1 = ${2:-};|" ./package.nix
}

REPO_NAME="awnion/custom-iosevka-nerd-font"
REPO_URL="https://github.com/$REPO_NAME"
API_URL="https://api.github.com/repos/$REPO_NAME"

RELEASES_JSON="$(curl -fsSL "$API_URL/releases")"
LATEST_JSON=$(jq 'map(select(.draft | not)) | .[0]' <<< "$RELEASES_JSON") # allow prereleases

LATEST_IS_RC="$(jq -r .prerelease <<< "$LATEST_JSON")"
LATEST_TAG="$(jq -r .tag_name <<< "$LATEST_JSON")"

if [ "$LATEST_IS_RC" = "true" ]; then
    LATEST_VERSION="$(sed -Ee "s|v([0-9]+\.[0-9]+\.[0-9]+)-rc|\1|" <<< "$LATEST_TAG")"
else
    LATEST_VERSION="$LATEST_TAG" 
fi

SRC_HASH=$(nurl -H "$REPO_URL" "$LATEST_TAG")

setKV version "\"$LATEST_VERSION\""
setKV afioHash "\"$SRC_HASH\""
setKV isRc "$LATEST_IS_RC"
