#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
VERSION=$(nix eval --raw .#inter-knot.version)
URL="https://raw.githubusercontent.com/share121/inter-knot/v${VERSION}/pubspec.lock"

wget "$URL" -O- | yq -j >"$SCRIPT_DIR/pubspec.lock.json"
