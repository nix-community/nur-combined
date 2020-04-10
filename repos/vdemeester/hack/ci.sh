#!/usr/bin/env bash
set -e

nix-channel --add ${CHANNEL} nixpkgs

nix-channel --list
nix-channel --update

if test "${CHANNEL}" = "https://nixos.org/channels/nixpkgs-unstable"; then
    curl -XPOST "https://nur-update.herokuapp.com/update?repo=vdemeester"
fi

$(dirname $0)/pkgs-build-cachix.sh
