#! /usr/bin/env nix-shell
#! nix-shell -i bash -p coreutils gnused curl jq nix-prefetch
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

attr_path=sevenzip

DRV_DIR="$PWD"

OLD_VERSION="$(sed -nE 's/\s*version = "(.*)".*/\1/p' ./sevenzip.nix)"
# The best_release.json is not always up-to-date
# In those cases you can force the version by calling `./update.sh <newer_version>`
# fix: use latest release
#NEW_VERSION="${1:-$(curl 'https://sourceforge.net/projects/sevenzip/best_release.json' | jq '.platform_releases.linux.filename' -r | cut -d/ -f3)}"
NEW_VERSION="${1:-$(curl 'https://sourceforge.net/projects/sevenzip/best_release.json' | jq '.release.filename' -r | cut -d/ -f3)}"

echo "comparing versions $OLD_VERSION => $NEW_VERSION"
if [[ "$OLD_VERSION" == "$NEW_VERSION" ]]; then
    echo "Already up to date! Doing nothing"
    exit 0
fi

NIXPKGS_ROOT="$(realpath "$DRV_DIR/../../../..")"

# debug
echo "NIXPKGS_ROOT: $NIXPKGS_ROOT"

set -x

echo "getting free source hash"
OLD_FREE_HASH="$(nix-instantiate --eval --strict -E "with import $NIXPKGS_ROOT {}; $attr_path.src.drvAttrs.outputHash" | tr -d '"')"
echo "getting unfree source hash"
OLD_UNFREE_HASH="$(nix-instantiate --eval --strict -E "with import $NIXPKGS_ROOT {}; ($attr_path.override { enableUnfree = true; }).src.drvAttrs.outputHash" | tr -d '"')"

NEW_VERSION_FORMATTED="$(echo "$NEW_VERSION" | tr -d '.')"
URL="https://7-zip.org/a/7z${NEW_VERSION_FORMATTED}-src.tar.xz"

# fix: nix-prefetch fails on nur-packages repo
# error: Could not find Nixpkgs path: /tmp/nur-packages/pkgs/top-level
#NEW_FREE_HASH=$(nix-prefetch -f "$NIXPKGS_ROOT" -E "$attr_path.src" --url "$URL")
NEW_FREE_HASH=$(nix-prefetch -f "<nixpkgs>" -E "(import $NIXPKGS_ROOT {}).$attr_path.src" --url "$URL")

#NEW_UNFREE_OUT=$(nix-prefetch -f "$NIXPKGS_ROOT" -E "($attr_path.override { enableUnfree = true; }).src" --url "$URL" --output raw --print-path)
NEW_UNFREE_OUT=$(nix-prefetch -f "<nixpkgs>" -E "((import $NIXPKGS_ROOT {}).$attr_path.override { enableUnfree = true; }).src" --url "$URL" --output raw --print-path)
# first line of raw output is the hash
NEW_UNFREE_HASH="$(echo "$NEW_UNFREE_OUT" | sed -n 1p)"
# second line of raw output is the src path
NEW_UNFREE_SRC="$(echo "$NEW_UNFREE_OUT" | sed -n 2p)"
# make sure to nuke the unfree src from the updater's machine
# > the license requires that you agree to these use restrictions, or you must remove the software (source and binary) from your hard disks
# https://fedoraproject.org/wiki/Licensing:Unrar
nix-store --delete "$NEW_UNFREE_SRC"


echo "updating version"
sed -i "s/version = \"$OLD_VERSION\";/version = \"$NEW_VERSION\";/" "$DRV_DIR/sevenzip.nix"

echo "updating free hash"
sed -i "s@free = \"$OLD_FREE_HASH\";@free = \"$NEW_FREE_HASH\";@" "$DRV_DIR/sevenzip.nix"
echo "updating unfree hash"
sed -i "s@unfree = \"$OLD_UNFREE_HASH\";@unfree = \"$NEW_UNFREE_HASH\";@" "$DRV_DIR/sevenzip.nix"

echo "done"
