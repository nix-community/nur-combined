#!/usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

node2nix \
  --node-env node-env.nix \
  --development \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix
