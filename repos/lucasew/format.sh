#! /usr/bin/env bash

nix-shell -p nixpkgs-fmt --run 'nixpkgs-fmt ./**/*.nix'
