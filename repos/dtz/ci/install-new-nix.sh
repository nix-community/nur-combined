#!/bin/sh

# Install recent-ish Nix for misc fixes.
# Attempt to "update" to it, for the day it's no longer "new".
# curl -LH "Content-Type: application/json" https://hydra.nixos.org/job/nix/master/build.x86_64-linux/latest|jq '.buildoutputs.out.path' -craM
nix-env -u /nix/store/4ip1pvkcb7khfb33r6yj1jkgk5v2zd6n-nix-2.3pre6631_e58a7144

