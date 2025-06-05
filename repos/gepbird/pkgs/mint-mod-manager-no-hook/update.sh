#!/usr/bin/env nix-shell
#!nix-shell --pure --keep NIX_PATH -i bash -p bash cacert nix-update git
nix-update mint-mod-manager --version branch --build
