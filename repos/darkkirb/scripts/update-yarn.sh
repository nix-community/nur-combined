#!/usr/bin/env nix-shell
#!nix-shell -i bash -p yarn2nix
SOURCE=$1
WRITE_PATH=$2

yarn2nix --lockfile $1/yarn.lock > $WRITE_PATH/yarn.nix
cp $1/package.json $1/yarn.lock $WRITE_PATH
