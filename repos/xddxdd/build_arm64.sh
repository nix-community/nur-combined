#!/bin/sh
nix build ".#packages.aarch64-linux.${1}" --show-trace
# cachix push xddxdd "$(readlink result)"
