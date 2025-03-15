#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p cargo -p gitMinimal
# shellcheck shell=bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
VERSION=$(nix eval --raw .#vgpu-unlock-rs.rawVersion)
TMPDIR=$(mktemp -d)
git clone https://github.com/mbilker/vgpu_unlock-rs.git $TMPDIR

pushd "$TMPDIR" || exit 1
git checkout "$VERSION"
cargo generate-lockfile
cp Cargo.lock "$SCRIPT_DIR/Cargo.lock"
popd || exit 1

rm -rf "$TMPDIR"
