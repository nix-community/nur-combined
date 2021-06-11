#!/usr/bin/env bash

ret=$(
  set +e
  # Timeout after 45m to ensure built derivations are cached before 50m time limit
  timeout=$(((2700 - ($(date +%s) - $START_TIME))))
  travis_wait nix-build ci.nix -A cacheOutputs --keep-going --timeout $timeout 1>&2
  echo $?
)

nix eval -f default.nix 'lib'
nix eval -f default.nix 'modules'
nix eval -f default.nix 'overlays'

if [ -n "${CACHIX_CACHE}" ]; then
  nix-build ci.nix -A cacheOutputs --dry-run | cachix push "${CACHIX_CACHE}";
fi

# Build remaining derivations that can't be cached
nix-build ci.nix -A buildOutputs --keep-going

if [ $ret -ne 0 ]; then
  exit $ret
fi
