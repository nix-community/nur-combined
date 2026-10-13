#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils gnused nix
# shellcheck shell=bash
# Sync the WeType APK and bionic image pins with the ones the pinned upstream
# source requires.

set -euo pipefail

PKG_DIR="$(dirname "$(readlink -f "$0")")"
ROOT="$(readlink -f "$PKG_DIR/../../../..")"
PKG_FILE="$PKG_DIR/package.nix"
NIX=(nix --extra-experimental-features "nix-command flakes")

SRC="$("${NIX[@]}" build --no-link --print-out-paths "$ROOT#wetype.src")"
FETCH_APK="$SRC/scripts/fetch_apk.py"
BIONIC="$SRC/scripts/prepare_bionic.sh"

# fetch_apk.py holds the APK pin; prepare_assets.sh only forwards to it.
VERSION="$(sed -n 's/^WETYPE_VERSION = "\(.*\)"$/\1/p' "$FETCH_APK")"
SHA256="$(sed -n 's/^WETYPE_APK_SHA256 = "\(.*\)"$/\1/p' "$FETCH_APK")"
# The URL is written as ".../%s/..." % WETYPE_VERSION, so drop the trailing
# format expression before substituting the version in.
URL="$(sed -n 's/^WETYPE_APK_URL = "\([^"]*\)".*$/\1/p' "$FETCH_APK")"
URL="${URL//%s/$VERSION}"

IMAGE_URL="$(sed -n 's/^IMAGE_URL=//p' "$BIONIC")"
IMAGE_SHA256="$(sed -n 's/^IMAGE_SHA256=//p' "$BIONIC")"

if [[ -z "$VERSION" || -z "$SHA256" || -z "$URL" ]]; then
  echo "Could not read the APK pin from $FETCH_APK" >&2
  exit 1
fi

if [[ -z "$IMAGE_URL" || -z "$IMAGE_SHA256" ]]; then
  echo "Could not read the bionic image pin from $BIONIC" >&2
  exit 1
fi

APK_HASH="$("${NIX[@]}" hash convert --hash-algo sha256 --to sri "$SHA256")"
IMAGE_HASH="$("${NIX[@]}" hash convert --hash-algo sha256 --to sri "$IMAGE_SHA256")"

sed -i \
  -e "/^    apk = fetchurl {/,/};/ s|url = \"[^\"]*\"|url = \"$URL\"|" \
  -e "/^    apk = fetchurl {/,/};/ s|hash = \"[^\"]*\"|hash = \"$APK_HASH\"|" \
  "$PKG_FILE"

sed -i \
  -e "/^  bionicImage = fetchurl {/,/};/ s|url = \"[^\"]*\"|url = \"$IMAGE_URL\"|" \
  -e "/^  bionicImage = fetchurl {/,/};/ s|hash = \"[^\"]*\"|hash = \"$IMAGE_HASH\"|" \
  "$PKG_FILE"

echo "WeType APK pinned to $VERSION ($URL)."
echo "Bionic image pinned to $IMAGE_URL."
