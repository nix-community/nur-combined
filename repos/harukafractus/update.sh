#!/bin/bash
set -e
trap "echo; exit" INT

pushd $(dirname "$0")/nur-everything/overlays/mac-apps
nix-shell -p 'with import <nixpkgs> {}; callPackage ./update.nix {}' --run "update-mac-apps"
popd

pushd $(dirname "$0")
nix flake update
popd


# sudo spctl --master-disable
# spctl developer-mode enable-terminal
