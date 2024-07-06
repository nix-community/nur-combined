#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
VERSION=$(nix eval --raw .#lyrica.version)
URL="https://github.com/chiyuki0325/lyrica/raw/v${VERSION}/Cargo.lock"

wget "$URL" -O "$SCRIPT_DIR/Cargo.lock"
