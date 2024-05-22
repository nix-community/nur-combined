#!/bin/sh
wget -O ./pkgs/golangci-lint/default.nix https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/development/tools/golangci-lint/default.nix
# nix-build -A golangci-lint
