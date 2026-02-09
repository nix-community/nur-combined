#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix perl moreutils

PKG_DIR="$(realpath "$(dirname "$0")")"
SOURCES_FILE="$PKG_DIR/sources.json"

update_platform() {
    local PLATFORM=$1
    local VERSION=$2
    local BUILD=$3
    local SIGN=$4
    local URL=$5
    local FILENAME=$6
    local OLD_VERSION=$(jq -r --arg p "$PLATFORM" '.[$p].version // ""' "$SOURCES_FILE")

    if [[ "$OLD_VERSION" == "$VERSION" ]]; then
        echo "$PLATFORM is already up to date ($VERSION)!"
        return
    fi

    local NEW_HASH=$(nix-prefetch-url --type sha256 "$URL" --name "$FILENAME")
    local SRI_HASH=$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 "$NEW_HASH")

    jq --arg version "$VERSION" \
       --arg sign "$SIGN" \
       --arg build "$BUILD" \
       --arg hash "$SRI_HASH" \
       --arg platform "$PLATFORM" \
       '.[$platform] = {version: $version, sign: $sign, build: $build, hash: $hash}' \
       "$SOURCES_FILE" | sponge "$SOURCES_FILE"
}

RAW_DATA=$(curl -sL "https://y.qq.com/download/download.js" | sed 's/^MusicJsonCallback(//;s/)$//' | base64)

# Mac
MAC_LINK=$(echo "$RAW_DATA" | base64 -d | jq -r \
    --arg title "Mac" '[.data[] | select(.Ftitle == $title)] | sort_by(.Fversion | sub("最新版:";"") | split(".") | map(tonumber)? // [0]) | last | .Flink1')
read -r MAC_VERSION MAC_BUILD MAC_SIGN <<< $(echo "$MAC_LINK" | sed -n 's/.*QQMusicMac\([0-9.]*\)Build\([0-9]*\)\.dmg.*sign=\(.*\)/\1 \2 \3/p')
MAC_URL="https://c.y.qq.com/cgi-bin/file_redirect.fcg?bid=dldir&file=ecosfile%2Fmusic_clntupate%2Fmac%2Fother%2FQQMusicMac${MAC_VERSION}Build${MAC_BUILD}.dmg&sign=${MAC_SIGN}"
for PLATFORM in "aarch64-darwin" "x86_64-darwin"; do
    update_platform "$PLATFORM" "$MAC_VERSION" "$MAC_BUILD" "$MAC_SIGN" "$MAC_URL" "QQMusicMac${MAC_VERSION}Build${MAC_BUILD}.dmg"
done

# Linux
LINUX_LINK=$(echo "$RAW_DATA" | base64 -d | jq -r \
    --arg title "Linux" '[.data[] | select(.Ftitle == $title)] | sort_by(.Fversion | sub("最新版:";"") | split(".") | map(tonumber)? // [0]) | last | .Flink1')
read -r LINUX_VERSION LINUX_SIGN <<< $(echo "$LINUX_LINK" | sed -n 's/.*qqmusic_\([0-9.]*\)_amd64.deb.*sign=\(.*\)/\1 \2/p')
LINUX_URL="https://c.y.qq.com/cgi-bin/file_redirect.fcg?bid=dldir&file=ecosfile_plink%2Fmusic_clntupate%2Flinux%2Fother%2Fqqmusic_${LINUX_VERSION}_amd64.deb&sign=${LINUX_SIGN}"
update_platform "x86_64-linux" "$LINUX_VERSION" "" "$LINUX_SIGN" "$LINUX_URL" "qqmusic_${LINUX_VERSION}_amd64.deb"
