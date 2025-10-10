#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#cabal2nix --command bash
# shellcheck shell=bash

set -euo pipefail

DIR="$(dirname "$0")"

cabal2nix --maintainer xyenon https://github.com/lazamar/nix-package-versions.git >"$DIR/cabal2nix.nix"
