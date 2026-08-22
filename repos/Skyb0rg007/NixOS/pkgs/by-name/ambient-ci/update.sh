#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p git -p gnused -p nix
# shellcheck shell=bash

set -euo pipefail

attr="${UPDATE_NIX_ATTR_PATH:-ambient-ci}"
relative="pkgs/by-name/ambient-ci/package.nix"

# `passthru.updateScript` runs this from a read-only copy in the nix store, so
# `BASH_SOURCE` is not where the package to edit lives. Update scripts are run
# with the flake root as the working directory (see scripts/nix-update.sh), so
# prefer that, and fall back to the checkout the script itself lives in for the
# case where it is executed straight out of a working tree.
root="$PWD"
package="$root/$relative"
if [ ! -w "$package" ]; then
    dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    if [ -w "$dir/package.nix" ]; then
        root="$(cd -- "$dir/../../.." && pwd)"
        package="$dir/package.nix"
    else
        echo "ambient-ci: cannot find a writable $relative; run this from the flake root" >&2
        exit 1
    fi
fi

seed="radicle.liw.fi"
repo="zwPaQSTBX8hktn22F6tHAZSFH2Fh"
node="z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"
url="https://$seed/$repo.git"

# nix-update knows nothing about `fetchFromRadicle`, so the hashes are
# discovered the same way it does it: write a placeholder, build, and read the
# real hash back out of the "hash mismatch" error.
fake_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# set_field <attribute> <value>: rewrite the first `<attribute> = "...";` line.
set_field() {
    local name=$1 value=$2 re
    re="^\\([[:space:]]*\\)$name = \"[^\"]*\";\$"
    sed -i "0,/$re/s|$re|\\1$name = \"$value\";|" "$package"
}

get_field() {
    sed -n "s|^[[:space:]]*$1 = \"\\([^\"]*\\)\";\$|\\1|p" "$package" | head -n 1
}

# build_for_hash <attribute>: build the package and, if it fails on a hash
# mismatch, store the hash nix actually got in `$got`. Returns non-zero when
# the build succeeded (nothing to update).
got=""
build_for_hash() {
    local log status
    got=""
    set +e
    log="$(nix build --no-link --print-build-logs "$root#$attr" 2>&1)"
    status=$?
    set -e

    if [ "$status" -eq 0 ]; then
        return 1
    fi

    got="$(printf '%s\n' "$log" \
        | sed -n 's|.*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]\{44\}\).*|\1|p' \
        | tail -n 1)"

    if [ -z "$got" ]; then
        printf '%s\n' "$log" >&2
        echo "ambient-ci: build failed without a hash mismatch, giving up" >&2
        exit 1
    fi
}

current="$(get_field version)"

latest="$(git ls-remote "$url" "refs/namespaces/$node/refs/tags/v*" \
    | sed -n 's:.*\trefs/namespaces/[A-Za-z0-9]\+/refs/tags/v\([0-9.]\+\).*:\1:p' \
    | sort -uV \
    | tail -n 1)"

if [ -z "$latest" ]; then
    echo "ambient-ci: no tags found at $url" >&2
    exit 1
fi

if [ "$current" = "$latest" ]; then
    echo "version $current is the latest, skipping"
    exit
fi

echo "ambient-ci: $current -> $latest"

backup="$(mktemp)"
cp "$package" "$backup"
restore() {
    if [ -n "${backup:-}" ]; then
        cp "$backup" "$package"
        rm -f "$backup"
    fi
}
trap 'restore' EXIT

set_field version "$latest"
set_field hash "$fake_hash"
set_field cargoHash "$fake_hash"

if build_for_hash; then
    echo "ambient-ci: src hash $got"
    set_field hash "$got"
fi

if build_for_hash; then
    echo "ambient-ci: cargoHash $got"
    set_field cargoHash "$got"
fi

# Keep the updated package.nix.
backup_kept="$backup"
backup=""
rm -f "$backup_kept"
trap - EXIT

echo "ambient-ci: updated to $latest"
