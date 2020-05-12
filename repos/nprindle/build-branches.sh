#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash

branches=("nixos-unstable" "nixpkgs-unstable" "nixos-20.03")
for branch in "${branches[@]}"; do
  echo "Building $branch..."
  pkgs="import (fetchTarball \"https://github.com/nixos/nixpkgs/archive/${branch}.tar.gz\") {}"
  nix-build ci.nix --arg pkgs "$pkgs" -j8 -Q -A buildOutputs | cachix push nprindle
done
