#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
VERSION=$(nix eval --raw .#helium-gateway-rs.rawVersion)
URL="https://github.com/helium/gateway-rs/raw/${VERSION}/Cargo.lock"

wget "$URL" -O "$SCRIPT_DIR/Cargo.lock"
