#!/bin/sh
wget -O ./pkgs/gopls/default.nix https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/by-name/go/gopls/package.nix
# nix-build -A gopls
