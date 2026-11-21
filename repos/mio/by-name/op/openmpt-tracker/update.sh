#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix nixfmt-rfc-style
# shellcheck shell=bash

# Bumps the MSVC tracker build to the newest libopenmpt-X.Y.Z tag. The tag feeds
# two coupled pins: `version` in windows.nix and package.nix, and the
# fetchFromGitHub source hash in windows.nix. openmpt123 is built from the same
# tarball and has its own script (by-name/op/openmpt123/update.sh); run both to
# keep the two packages on the same release.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
dir=by-name/op/openmpt-tracker

tag=$(
    curl -fsSL --retry 3 "https://api.github.com/repos/OpenMPT/openmpt/tags?per_page=100" |
        jq -r '.[].name' |
        grep -E '^libopenmpt-[0-9]+(\.[0-9]+)+$' |
        sort -V |
        tail -n 1
)
if [ -z "$tag" ]; then
    echo "update.sh: no libopenmpt-X.Y.Z tag found" >&2
    exit 1
fi
version=${tag#libopenmpt-}
echo "update.sh: $version"

# fetchFromGitHub hashes the unpacked tree, so ask Nix for the same unpacked
# hash instead of the tarball's own.
hash=$(
    nix store prefetch-file --unpack --json \
        "https://github.com/OpenMPT/openmpt/archive/refs/tags/${tag}.tar.gz" |
        jq -r .hash
)
echo "update.sh: src $hash"

# Keep every indent width: package.nix sits at two spaces, windows.nix is
# nested inside finalAttrs.
for f in "$dir/windows.nix" "$dir/package.nix"; do
    sed -i.bak -E "s|^([[:space:]]*)version = \"[^\"]*\";|\1version = \"${version}\";|" "$f"
    rm -f "$f.bak"
done
sed -i.bak -E "s|^([[:space:]]*)hash = \"sha256-[A-Za-z0-9+/=]+\";|\1hash = \"${hash}\";|" "$dir/windows.nix"
rm -f "$dir/windows.nix.bak"

nixfmt "$dir/windows.nix" "$dir/package.nix"
git --no-pager diff --stat -- "$dir"
