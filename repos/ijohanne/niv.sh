#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
nix-shell --run "niv $*"
