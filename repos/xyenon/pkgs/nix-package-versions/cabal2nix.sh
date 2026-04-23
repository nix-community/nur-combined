#!/usr/bin/env nix-shell
#!nix-shell -i bash -p cabal2nix
# shellcheck shell=bash

set -euo pipefail

DIR="$(dirname "$0")"

cabal2nix --maintainer xyenon https://github.com/lazamar/nix-package-versions.git >"$DIR/cabal2nix.nix"
