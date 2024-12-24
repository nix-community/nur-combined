#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update

nix-update --version-regex='makerom-v(.*)' makerom
nix-update --version-regex='ctrtool-v(.*)' ctrtool

cat $(nix-build --no-out-link --builders '' build-readme.nix) > README.md
