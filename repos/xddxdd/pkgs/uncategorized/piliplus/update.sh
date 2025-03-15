#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p yq
# shellcheck shell=bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
VERSION=$(nix eval --raw .#piliplus.version)

curl https://raw.githubusercontent.com/bggRGjQaUbCoE/PiliPlus/refs/tags/$VERSION/pubspec.lock | yq . >$SCRIPT_DIR/pubspec.lock.json
