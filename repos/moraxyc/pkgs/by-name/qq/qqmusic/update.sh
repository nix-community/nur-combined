#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git curl jq nix moreutils
# shellcheck shell=bash

set -euo pipefail

NIXPKGS="$(git rev-parse --show-toplevel)"
PKG_DIR="$NIXPKGS/pkgs/by-name/qq/qqmusic"
SOURCES_FILE="$PKG_DIR/sources.json"

is_empty_or_null() {
    local VALUE=$1
    [[ -z "$VALUE" || "$VALUE" == "null" ]]
}

update_platform() {
    local PLATFORM=$1
    local TITLE=$2
    local FILENAME_TEMPLATE=$3

    local RESOLVED
    RESOLVED=$(jq -r --arg title "$TITLE" '
        [.data[] | select(.Ftitle == $title and (.Flink1 // "") != "")]
        | sort_by(.Fversion | tostring | sub("^最新版:\\s*"; "") | split(".") | map(tonumber? // 0))
        | last // empty
        | [(.Fversion // "" | tostring | sub("^最新版:\\s*"; "") | gsub("^\\s+|\\s+$"; "")), .Flink1]
        | @tsv
    ' <<< "$RAW_DATA")

    local VERSION=""
    local URL=""
    IFS=$'\t' read -r VERSION URL <<< "$RESOLVED"

    if is_empty_or_null "$VERSION" || is_empty_or_null "$URL"; then
        echo "Error: failed to resolve metadata for $PLATFORM ($TITLE)." >&2
        return 1
    fi

    if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+)*$ ]] || [[ ! "$URL" =~ ^https?:// ]]; then
        echo "Error: invalid metadata for $PLATFORM ($TITLE): version='$VERSION' url='$URL'" >&2
        return 1
    fi

    local FILENAME="${FILENAME_TEMPLATE//\{version\}/$VERSION}"
    local OLD_VERSION
    local OLD_URL
    OLD_VERSION=$(jq -r --arg p "$PLATFORM" '.[$p].version // ""' "$SOURCES_FILE")
    OLD_URL=$(jq -r --arg p "$PLATFORM" '.[$p].url // ""' "$SOURCES_FILE")

    if [[ "$OLD_VERSION" == "$VERSION" && "$OLD_URL" == "$URL" ]]; then
        echo "$PLATFORM is already up to date ($VERSION)!"
        return 0
    fi

    local NEW_HASH
    local SRI_HASH
    NEW_HASH=$(nix-prefetch-url --type sha256 "$URL" --name "$FILENAME")
    SRI_HASH=$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 "$NEW_HASH")

    jq --arg version "$VERSION" \
       --arg url "$URL" \
       --arg hash "$SRI_HASH" \
       --arg platform "$PLATFORM" \
       '.[$platform] = {version: $version, url: $url, hash: $hash}' \
       "$SOURCES_FILE" | sponge "$SOURCES_FILE"
}

RAW_DATA=$(curl -fsSL "https://y.qq.com/download/download.js" | sed 's/^MusicJsonCallback(//;s/);*$//')

if is_empty_or_null "$RAW_DATA"; then
    echo "Error: download payload is empty, keeping sources.json unchanged." >&2
    exit 1
fi

update_platform "any-darwin" "Mac" "QQMusicMac-{version}.dmg"
update_platform "x86_64-linux" "Linux" "qqmusic_{version}_amd64.deb"
