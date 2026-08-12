#!/usr/bin/env bash
# Build a Debian source package into _build/.
# Needs only dpkg; never runs debian/rules, so it works on non-Debian hosts.
set -euo pipefail

pkg="$1"
top="$(cd "$(dirname "$0")/.." && pwd)"
dir="$top/pkgs/$pkg"
build="${DEB_BUILD_DIR:-$top/_build}"

src="$(dpkg-parsechangelog --file "$dir/debian/changelog" --show-field Source)"
ver="$(dpkg-parsechangelog --file "$dir/debian/changelog" --show-field Version)"
uver="${ver%-*}"
tree="$build/$src-$uver"

rm -rf "$tree"
mkdir -p "$tree"

if [ -f "$dir/upstream.json" ]; then
    orig="$build/${src}_${uver}.orig.tar.gz"
    [ -f "$orig" ] || curl -fsSL -o "$orig" "$(jq -r .url "$dir/upstream.json")"
    echo "$(jq -r .sha256 "$dir/upstream.json")  $orig" | sha256sum --check --strict
    tar -xf "$orig" --strip-components=1 -C "$tree"
else
    tar -c -C "$dir" --exclude=./debian . | tar -x -C "$tree"
fi

# Optional hook, e.g. to vendor dependencies into an orig-<component> tarball.
[ ! -x "$dir/prepare" ] || "$dir/prepare" "$tree" "$build/${src}_${uver}"

cp -a "$dir/debian" "$tree"
cd "$build" && dpkg-source -b "$src-$uver"

# Leave only artifacts behind; debcraft unpacks the .dsc into this same path.
rm -rf "$tree"
