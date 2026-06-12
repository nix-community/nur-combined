#!/usr/bin/env bash

shopt -s nullglob

for pkg in ./pkgs/*; do
    pkg=$(basename "$pkg")
    echo nix-update "$pkg"
    nix-update "$pkg" &
done

wait

git status
