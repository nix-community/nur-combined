#!/usr/bin/env bash

set -e -o pipefail

if [ -n "${CACHIX_CACHE}" ]; then
   travis_retry nix-channel --update
   sudo nix-env -iA cachix -f https://cachix.org/api/v1/install
   sudo cachix use "${CACHIX_CACHE}"
fi

nix-channel --add "${NIX_CHANNEL}" nixpkgs
travis_retry nix-channel --update
