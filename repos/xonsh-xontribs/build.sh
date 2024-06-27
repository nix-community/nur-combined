#!/usr/bin/env bash

set -e
set -x

for f in $(ls -1b pkgs/); do
    echo "Building $f"
    nix-build --arg pkgs 'import <nixpkgs> {}' -A $f
done