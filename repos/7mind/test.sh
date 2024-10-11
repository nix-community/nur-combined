#!/usr/bin/env bash

rm result-*

nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached ci.nix -A cacheOutputs
