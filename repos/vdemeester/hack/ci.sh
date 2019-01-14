#!/usr/bin/env bash
set -e

nix-channel --list

nix-channel --add ${CHANNEL} nixpkgs

nix-channel --list
nix-channel --update

$(dirname $0)/pkgs-build-cachix.sh
