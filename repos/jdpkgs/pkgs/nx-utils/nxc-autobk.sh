#!/usr/bin/env bash
# copies the nix config files to the specified directory (arg #1)

dt=$(date +'%m.%d.%Y-%I:%M.%p')
bkpath=($1)
dir=$bkpath/$dt/

mkdir -p $dir
cp -r /etc/nixos/*.nix $dir 

