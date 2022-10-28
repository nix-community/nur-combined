#!/usr/bin/env nix-shell
#!nix-shell -i bash -p mix2nix
SOURCE_DIR=$1
MIX2NIX_OUT=$2

mix2nix $SOURCE_DIR/mix.lock > $MIX2NIX_OUT