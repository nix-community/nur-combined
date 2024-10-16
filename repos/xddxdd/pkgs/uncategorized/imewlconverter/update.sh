#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
TMPFILE=$(mktemp -u)

rm -f "$SCRIPT_DIR/deps.nix"
nix build .#imewlconverter.fetch-deps -o "$TMPFILE"
yes | bash "$TMPFILE" "$SCRIPT_DIR/deps.nix"
