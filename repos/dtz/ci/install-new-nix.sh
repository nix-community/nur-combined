#!/bin/sh

# Install recent-ish Nix for misc fixes.
# Attempt to "update" to it, for the day it's no longer "new".
# curl -LH "Content-Type: application/json" https://hydra.nixos.org/job/nix/master/build.x86_64-linux/latest|jq '.buildoutputs.out.path' -craM
nix-env -u /nix/store/pdqlzmdjxkjv63f9l72ckhfdfik101i9-nix-2.2pre6494_bd78544f
