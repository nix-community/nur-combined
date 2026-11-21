#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix nix-update nixfmt-rfc-style
# shellcheck shell=bash

# Bumps BeamNG.Earth to the newest release tag (vX.Y.Z-beta; the rolling
# vX.Y.Z-beta.dev.N tags are development snapshots) and refreshes both coupled
# pins: the fetchFromGitHub source hash and native/earthfast's cargoHash, which
# moves whenever upstream changes Cargo.lock.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
dir=by-name/be/beamng-earth

tag=$(
    curl -fsSL --retry 3 "https://api.github.com/repos/TecnaGamer/BeamNG.Earth/tags?per_page=100" |
        jq -r '.[].name' |
        grep -E '^v[0-9]+\.[0-9]+\.[0-9]+-beta$' |
        sort -V |
        tail -n 1
)
if [ -z "$tag" ]; then
    echo "update.sh: no vX.Y.Z-beta release tag found" >&2
    exit 1
fi
version=${tag#v}
echo "update.sh: $version"

nix-update --version "$version" beamng-earth

# Re-resolve the vendored crates hash against the new Cargo.lock. nix-update
# only knows the top-level src hash, so ask the earthfast derivation itself:
# fake the hash, build the fixed-output dependency, read the reported one.
old_hash=$(sed -n 's/^    cargoHash = "\(.*\)";$/\1/p' "$dir/package.nix" | head -n 1)
if [ -z "$old_hash" ]; then
    echo "update.sh: no cargoHash in $dir/package.nix" >&2
    exit 1
fi
sed -i 's/^    cargoHash = ".*";$/    cargoHash = lib.fakeHash;/' "$dir/package.nix"
if ! out=$(nix build --no-link .#beamng-earth.earthfast 2>&1); then
    new_hash=$(sed -n 's/.*got: *\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' <<<"$out" | tail -n 1)
    if [ -z "$new_hash" ]; then
        sed -i "s|^    cargoHash = lib.fakeHash;$|    cargoHash = \"$old_hash\";|" "$dir/package.nix"
        echo "$out" >&2
        echo "update.sh: earthfast failed to build and reported no hash" >&2
        exit 1
    fi
    sed -i "s|^    cargoHash = lib.fakeHash;$|    cargoHash = \"$new_hash\";|" "$dir/package.nix"
fi

nixfmt "$dir/package.nix"
