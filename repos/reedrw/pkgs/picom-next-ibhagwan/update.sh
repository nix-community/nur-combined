#!/usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

nix-prefetch-github  --fetch-submodules \
  ibhagwan picom | tee source.json
