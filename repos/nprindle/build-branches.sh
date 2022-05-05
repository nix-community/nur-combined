#!/bin/sh

if [ $# -eq 0 ]; then
  branches=( "nixos-unstable" "nixpkgs-unstable" )
else
  branches=( "$@" )
fi

echo "Branches to build: ${branches[@]}"

for branch in "${branches[@]}"; do
  echo "Building $branch..."
  pkgs="import (fetchTarball \"https://github.com/nixos/nixpkgs/archive/${branch}.tar.gz\") {}"
  nix-build ci.nix --arg pkgs "$pkgs" -j8 --keep-going -A buildOutputs | cachix push nprindle
done

