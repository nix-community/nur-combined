#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix nixfmt-rfc-style
# shellcheck shell=bash

# Bumps the openmpt123 cross build to the newest libopenmpt-X.Y.Z tag. The tag
# feeds three coupled pins: `version` in windows.nix and package.nix, and the
# fetchFromGitHub source hash in windows.nix. Anything else in the build is
# derived (the mingw-w64 config disables every optional library), so no other
# pin moves.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
dir=by-name/op/openmpt123

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

for f in "$dir/windows.nix" "$dir/package.nix"; do
    sed -i.bak -E "s|^  version = \"[^\"]*\";|  version = \"${version}\";|" "$f"
    rm -f "$f.bak"
done
sed -i.bak -E "s|^    hash = \"sha256-[A-Za-z0-9+/=]+\";|    hash = \"${hash}\";|" "$dir/windows.nix"
rm -f "$dir/windows.nix.bak"

nixfmt "$dir/windows.nix" "$dir/package.nix"
git --no-pager diff --stat -- "$dir"
