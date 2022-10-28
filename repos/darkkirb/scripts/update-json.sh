#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl
URL=$1
WRITE_PATH=$2

curl -L $URL > $WRITE_PATH