#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p git -p gnused -p jq
# shellcheck shell=bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
NEW_TAG=$(git ls-remote --tags https://github.com/feder-cr/invisible-firefox | sed -n 's#.*refs/tags/firefox-\([0-9]\+\)$#\1#p' | sort -n | tail -1)
NEW_VERSION=$(curl -sL "https://raw.githubusercontent.com/feder-cr/invisible-firefox/firefox-$NEW_TAG/browser/config/version.txt")
if [ "$NEW_VERSION" = "${UPDATE_NIX_OLD_VERSION:-}" ]; then
  exit 0
fi
NEW_HASH=$(nix store prefetch-file --json --unpack "https://github.com/feder-cr/invisible-firefox/archive/refs/tags/firefox-$NEW_TAG.tar.gz" | jq -r .hash)
sed -i "s/tag = \"firefox-[0-9]*\"/tag = \"firefox-$NEW_TAG\"/" "$SCRIPT_DIR/default.nix"
sed -i "s/hash = \"sha256-[^\"]*\"/hash = \"$NEW_HASH\"/" "$SCRIPT_DIR/default.nix"
sed -i "s/version = \"[0-9.]*\"/version = \"$NEW_VERSION\"/" "$SCRIPT_DIR/default.nix"
