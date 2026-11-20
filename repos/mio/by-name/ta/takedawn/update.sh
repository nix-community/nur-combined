#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update nixfmt-rfc-style python3
# shellcheck shell=bash

# Bumps Takedawn and the xboxrecomp toolkit tag that goes with it.
#
# Both pins move together: every Takedawn release has a takedawn-<version> tag
# in the toolkit, and fetchFromGitHub's hash is over the unpacked tree, so the
# toolkit hash is recomputed from the tag's archive.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
dir=by-name/ta/takedawn

nix-update takedawn --version-regex 'v(.*)'
version=$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$dir/package.nix" | head -1)
if [ -z "$version" ]; then
    echo "update.sh: no version in $dir/package.nix" >&2
    exit 1
fi

tag="takedawn-$version"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
archive=$(
    nix store prefetch-file --json \
        "https://github.com/xenophobentx/xboxrecomp/archive/refs/tags/$tag.tar.gz" |
        python3 -c 'import json, sys; print(json.load(sys.stdin)["storePath"])'
)
tar -xf "$archive" -C "$tmp" --strip-components=1
hash=$(nix hash path --sri "$tmp")

cat >"$dir/toolkit.nix" <<EOF
# Updated by update.sh along with the version in package.nix: each Takedawn
# release has a takedawn-<version> tag in the toolkit.
{ fetchFromGitHub }:
fetchFromGitHub {
  owner = "xenophobentx";
  repo = "xboxrecomp";
  tag = "$tag";
  hash = "$hash";
}
EOF
nixfmt "$dir/toolkit.nix"
