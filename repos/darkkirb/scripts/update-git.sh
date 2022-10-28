#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git
URL=$1
WRITE_PATH=$2

nix-prefetch-git $3 $URL | grep -v "Git " > $WRITE_PATH