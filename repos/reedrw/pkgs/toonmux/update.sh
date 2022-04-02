#!/usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

nix-prefetch-github  --fetch-submodules \
  JonathanHelianthicusDoe toonmux | tee source.json
