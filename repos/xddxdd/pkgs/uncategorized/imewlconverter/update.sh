#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
TMPFILE=$(mktemp -u)

rm -f "$SCRIPT_DIR/deps.nix"
nix build .#imewlconverter.fetch-deps -o "$TMPFILE"
yes | bash "$TMPFILE" "$SCRIPT_DIR/deps.json"

jq 'map(select(.pname | contains("Microsoft.") | not))' "$SCRIPT_DIR/deps.json" >"$SCRIPT_DIR/deps.json.tmp"
mv "$SCRIPT_DIR/deps.json.tmp" "$SCRIPT_DIR/deps.json"
