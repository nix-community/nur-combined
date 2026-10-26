#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p git -p gnused -p jq
# shellcheck shell=bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"

NEW_REV=$(git ls-remote --tags https://github.com/feder-cr/firefox_antidetect_patch | sed -n 's#.*refs/tags/firefox-\([0-9]\+\)$#\1#p' | sort -n | tail -1)
[ -n "$NEW_REV" ] || {
  echo "no firefox-N tags found upstream" >&2
  exit 1
}
OLD_REV=$(sed -n 's/^  tag = "firefox-\([0-9]\+\)";$/\1/p' default.nix)
if [ "$NEW_REV" = "$OLD_REV" ]; then
  exit 0
fi
NEW_TAG="firefox-$NEW_REV"

ASSETS=$(curl -sL "https://github.com/feder-cr/firefox_antidetect_patch/releases/expanded_assets/$NEW_TAG")
NEW_VERSION=$(sed -n 's#.*firefox-\([0-9.]*\)-stealth-linux-x86_64\.tar\.gz.*#\1#p' <<<"$ASSETS" | head -1)
[ -n "$NEW_VERSION" ] || {
  echo "cannot determine Firefox version from $NEW_TAG assets" >&2
  exit 1
}

H_X86=$(nix store prefetch-file --json "https://github.com/feder-cr/firefox_antidetect_patch/releases/download/$NEW_TAG/firefox-$NEW_VERSION-stealth-linux-x86_64.tar.gz" | jq -r .hash)
H_ARM=$(nix store prefetch-file --json "https://github.com/feder-cr/firefox_antidetect_patch/releases/download/$NEW_TAG/firefox-$NEW_VERSION-stealth-linux-arm64.tar.gz" | jq -r .hash)

sed -i "s/^  tag = \"firefox-[0-9]*\";$/  tag = \"$NEW_TAG\";/" default.nix
sed -i "s/^  version = \"[0-9.]*\";$/  version = \"$NEW_VERSION\";/" default.nix
sed -i "s|^    x86_64-linux = \"sha256-[^\"]*\";|    x86_64-linux = \"$H_X86\";|" default.nix
sed -i "s|^    aarch64-linux = \"sha256-[^\"]*\";|    aarch64-linux = \"$H_ARM\";|" default.nix

nix build .#invisible-firefox-bin.unwrapped.src
