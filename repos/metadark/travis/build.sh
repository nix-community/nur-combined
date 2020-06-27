#!/usr/bin/env bash

# Build & cache cacheable outputs
if [ -n "${CACHIX_CACHE}" ]; then
  nix-build ci.nix -A cacheOutputs --keep-going | cachix push "${CACHIX_CACHE}"
fi

# Build remaining non cacheable outputs
nix-build ci.nix -A buildOutputs --keep-going

nix eval -f default.nix 'lib'
nix eval -f default.nix 'modules'
nix eval -f default.nix 'overlays'
