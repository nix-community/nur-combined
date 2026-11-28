#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p git -p gnused -p jq
# shellcheck shell=bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO=https://github.com/feder-cr/invisible-firefox
TAGS=$(git ls-remote --tags "$REPO") || {
    echo "WARN: $REPO is gone; keeping the current Firefox source" >&2
    exit 0
}
NEW_TAG=$(sed -n 's#.*refs/tags/firefox-\([0-9]\+\)$#\1#p' <<<"$TAGS" | sort -n | tail -1)
[ -n "$NEW_TAG" ] || {
    echo "WARN: $REPO has no firefox-N tags; keeping the current Firefox source" >&2
    exit 0
}
NEW_SOURCE=$(nix store prefetch-file --json --unpack "https://github.com/feder-cr/invisible-firefox/archive/refs/tags/firefox-$NEW_TAG.tar.gz")
SOURCE_PATH=$(jq -er .storePath <<<"$NEW_SOURCE")
if [ ! -f "$SOURCE_PATH/browser/config/version.txt" ]; then
    echo "Skipping firefox-$NEW_TAG: upstream archive no longer contains full Firefox source" >&2
    exit 0
fi
NEW_VERSION=$(<"$SOURCE_PATH/browser/config/version.txt")
if [ "$NEW_VERSION" = "${UPDATE_NIX_OLD_VERSION:-}" ]; then
    exit 0
fi
NEW_HASH=$(jq -er .hash <<<"$NEW_SOURCE")
sed -i "s/tag = \"firefox-[0-9]*\"/tag = \"firefox-$NEW_TAG\"/" "$SCRIPT_DIR/default.nix"
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$NEW_HASH\"|" "$SCRIPT_DIR/default.nix"
sed -i "s/version = \"[0-9.]*\"/version = \"$NEW_VERSION\"/" "$SCRIPT_DIR/default.nix"
