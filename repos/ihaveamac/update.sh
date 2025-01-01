#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update

nix-update --version-regex='makerom-v(.*)' makerom
nix-update --version-regex='ctrtool-v(.*)' ctrtool
#nix-update --version=branch ctrtool-dev

nix-shell build-readme.nix
