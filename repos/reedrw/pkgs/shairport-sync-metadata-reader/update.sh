#!/usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

nix-prefetch-github --fetch-submodules \
  mikebrady shairport-sync-metadata-reader | tee source.json
