#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils gnused nix
# shellcheck shell=bash
# Sync the WeType APK pin with the one required by the pinned upstream source.

set -euo pipefail

PKG_DIR="$(dirname "$(readlink -f "$0")")"
ROOT="$(readlink -f "$PKG_DIR/../../../..")"
PKG_FILE="$PKG_DIR/package.nix"
NIX=(nix --extra-experimental-features "nix-command flakes")

SRC="$("${NIX[@]}" build --no-link --print-out-paths "$ROOT#wetype.src")"
PREPARE="$SRC/scripts/prepare_assets.sh"

VERSION="$(sed -n 's/^WETYPE_VERSION=//p' "$PREPARE")"
SHA256="$(sed -n 's/^WETYPE_APK_SHA256=//p' "$PREPARE")"
URL="$(sed -n 's/^WETYPE_APK_URL="\(.*\)"$/\1/p' "$PREPARE")"
URL="${URL//\$WETYPE_VERSION/$VERSION}"

if [[ -z "$VERSION" || -z "$SHA256" || -z "$URL" ]]; then
  echo "Could not read the APK pin from $PREPARE" >&2
  exit 1
fi

HASH="$("${NIX[@]}" hash convert --hash-algo sha256 --to sri "$SHA256")"

sed -i \
  -e "/^    apk = fetchurl {/,/};/ s|url = \"[^\"]*\"|url = \"$URL\"|" \
  -e "/^    apk = fetchurl {/,/};/ s|hash = \"[^\"]*\"|hash = \"$HASH\"|" \
  "$PKG_FILE"

echo "WeType APK pinned to $VERSION ($URL)."
