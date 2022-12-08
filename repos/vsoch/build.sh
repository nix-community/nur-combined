#!/bin/bash
nix-build --arg pkgs 'import <nixpkgs> {}' -A ${1}