#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git nix nix-update jq moreutils
# shellcheck shell=bash
set -euo pipefail

PKG_DIR="$(realpath "$(dirname "$0")")"
if [[ ! -w "$PKG_DIR" ]]; then
    REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    if [[ -n "$REPO_ROOT" ]]; then
        PKG_DIR="$REPO_ROOT/pkgs/by-name/cr/cronet-go"
    fi
fi
PGO_JSON="$PKG_DIR/pgo.json"

echo "fetching source..."
SRC="$(nix-build -A cronet-go.src --no-link)"

update_pgo() {
    local NIX_KEY="$1"
    local TARGET="$2"

    local PGO_FILE="$SRC/naiveproxy/src/chrome/build/$TARGET.pgo.txt"
    if [[ ! -f "$PGO_FILE" ]]; then
        echo "  skip $NIX_KEY"
        return
    fi

    local PROFILE_NAME
    PROFILE_NAME="$(tr -d '\n' < "$PGO_FILE")"
    local URL="https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/$PROFILE_NAME"

    local OLD_NAME
    OLD_NAME="$(jq -r --arg k "$NIX_KEY" '.[$k].name' "$PGO_JSON")"
    if [[ "$OLD_NAME" == "$PROFILE_NAME" ]]; then
        echo "  $NIX_KEY unchanged"
        return
    fi

    local RAW_HASH SRI_HASH
    RAW_HASH="$(nix-prefetch-url --type sha256 "$URL")"
    SRI_HASH="$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 "$RAW_HASH")"
    echo "  $NIX_KEY -> $PROFILE_NAME -> $SRI_HASH"

    jq --arg k "$NIX_KEY" \
       --arg name "$PROFILE_NAME" \
       --arg hash "$SRI_HASH" \
       '.[$k] = {name: $name, hash: $hash}' \
       "$PGO_JSON" | sponge "$PGO_JSON"
}

echo "updating pgo..."
update_pgo "any-linux"      "linux"
update_pgo "x86_64-darwin"  "mac"
update_pgo "aarch64-darwin" "mac-arm"

echo "updating vendorHash..."
nix-update cronet-go.build-naive --override-filename "$PKG_DIR/build-naive.nix" --version=skip || {
    echo "  skip (vendorHash unchanged)"
}
