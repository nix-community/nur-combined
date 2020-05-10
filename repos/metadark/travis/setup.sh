#!/usr/bin/env bash

set -e

if [ -n "${CACHIX_CACHE}" ]; then
   travis_retry nix-channel --update
   nix-env -iA cachix -f https://cachix.org/api/v1/install
   if [ "${TRAVIS_OS_NAME}" == "osx" ]; then
       sudo cachix use "${CACHIX_CACHE}"
   else
       cachix use "${CACHIX_CACHE}"
   fi
fi

nix-channel --add "${NIX_CHANNEL}" nixpkgs
travis_retry nix-channel --update
