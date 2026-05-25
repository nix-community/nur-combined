#!/usr/bin/env nix-shell
#!nix-shell -i bash -p go nix-update
# shellcheck shell=bash

set -euo pipefail

NIXPKGS="$(git rev-parse --show-toplevel)"
PKG_DIR="$NIXPKGS/pkgs/by-name/bw/bw-ssh-agent-filter"

pushd "$PKG_DIR"
go mod tidy
popd

nix-update bw-ssh-agent-filter --version=skip || {
    echo "  skip (vendorHash unchanged)"
}
