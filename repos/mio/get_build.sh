#!/bin/sh
NIXPKGS=$(nix-instantiate --eval -E '<nixpkgs>' | tr -d '\"')
grep -A 10 "jps-bootstrap" $NIXPKGS/pkgs/applications/editors/jetbrains/source/build.nix
