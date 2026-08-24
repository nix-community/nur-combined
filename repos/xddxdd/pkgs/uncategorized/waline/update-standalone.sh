#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p nodejs
# shellcheck shell=bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

nix build .#waline.src -o $TMPDIR/source.tgz
tar xzf "$TMPDIR/source.tgz" -C "$TMPDIR"
cd "$TMPDIR/package" || exit 1
npm install --package-lock-only --ignore-scripts --force
cp package-lock.json "$SCRIPT_DIR/package-lock.json"
