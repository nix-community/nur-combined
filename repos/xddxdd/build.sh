#!/bin/sh
nix build ".#packages.x86_64-linux.${1}"
cachix push xddxdd "$(readlink result)"
