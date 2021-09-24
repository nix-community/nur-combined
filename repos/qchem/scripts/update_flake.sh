#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nixUnstable

nix --experimental-features 'nix-command flakes' flake update
git commit -m "update flake.lock" flake.lock
