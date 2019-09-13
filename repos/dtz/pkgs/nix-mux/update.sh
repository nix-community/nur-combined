#!/bin/sh

set -euo pipefail

# Build nix-mux, package into tarball:
NIX_PATH=nixpkgs=channel:nixos-unstable:$NIX_PATH \
  nix build -f gen.nix package  -o package --builders ""

# Post tarball onto cachix
cachix push allvm ./package

# Get info about the path from cachix:
# (and use jq to pretty-print/format)
nix path-info \
  --store https://allvm.cachix.org \
  ./package \
  --json \
  --option narinfo-cache-positive-ttl 0 \
  --option narinfo-cache-negative-ttl 0 \
  | jq > path-info.json

# Extract fields of interest
jq -C '.[] | {url,narHash}' < path-info.json

# Grab version too, or at least the changing part:
nix eval allvm.nix-mux.VERSION_SUFFIX

# For now, update default.nix manually using the above info
