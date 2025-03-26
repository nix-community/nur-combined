#!/bin/sh
wget -O ./pkgs/golangci-lint/default.nix https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/master/pkgs/by-name/go/golangci-lint/package.nix
# nix-build -A golangci-lint
