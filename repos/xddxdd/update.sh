#!/bin/sh
nix flake update
nvfetcher -c nvfetcher.toml -o _sources
