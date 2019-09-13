#!/bin/sh

# Install recent-ish Nix for misc fixes.
# Attempt to "update" to it, for the day it's no longer "new".
# curl -LH "Content-Type: application/json" https://hydra.nixos.org/job/nix/master/build.x86_64-linux/latest|jq '.buildoutputs.out.path' -craM
nix-env -u /nix/store/m4lk4ib1zx2nm2wg1hc81a0mx0m2jppr-nix-2.4pre6911_a56b51a0

