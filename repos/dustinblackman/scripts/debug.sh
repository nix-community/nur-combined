#!/usr/bin/env bash

PROGDIR=$(cd "$(dirname "$0")" && pwd)
cd "$PROGDIR/.."

DOCKER_DEFAULT_PLATFORM=linux/amd64 docker run -it -v "$PWD":/app nixos/nix:latest nix-shell --option filter-syscalls false -p "
let
  pkgs = import <nixpkgs> {};
in
pkgs.callPackage /app/pkgs/$1.nix {}
"
