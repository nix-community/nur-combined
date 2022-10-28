#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch
PACKAGE_PATH=$1
WRITE_PATH=$2

nix-prefetch "{ sha256 }: (callPackage (import $PACKAGE_PATH) { }).go-modules.overrideAttrs (_: { modSha256 = sha256; })" > $WRITE_PATH
