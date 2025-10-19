#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update

nix-update --version-regex='makerom-v(.*)' makerom
nix-update --version-regex='ctrtool-v(.*)' ctrtool
nix-update --version=branch wfs-tools
nix-update --version=branch _3beans
nix-update retro-aim-server
#nix-update tiny-wii-backup-manager

nix-shell build-readme.nix
