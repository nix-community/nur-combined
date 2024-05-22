#!/bin/sh
wget -O ./pkgs/gopls/default.nix https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/development/tools/language-servers/gopls/default.nix
# nix-build -A gopls
