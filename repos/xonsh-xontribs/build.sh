#!/usr/bin/env bash

set -e
set -x

if [ "$1" != "" ]; then
    FILES="$1"
else
    FILES="$(ls -1b pkgs/)"
fi

for f in $FILES; do
    if [ "$f" == "xontrib-jedi" ]; then continue; fi
    echo "Building $f"
    nix-build --arg pkgs 'import <nixpkgs> {}' -A $f
done
