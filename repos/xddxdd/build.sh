#!/bin/sh
nix build ".#packages.x86_64-linux.${1}" --show-trace
cachix push xddxdd "$(readlink result)"
