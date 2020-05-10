#!/usr/bin/env bash

nix-build ci.nix -A buildOutputs --keep-going

nix eval -f default.nix 'lib'
nix eval -f default.nix 'modules'
nix eval -f default.nix 'overlays'

if [ -n "${CACHIX_CACHE}" ]; then
  nix-build ci.nix -A cacheOutputs | cachix push "${CACHIX_CACHE}";
fi
