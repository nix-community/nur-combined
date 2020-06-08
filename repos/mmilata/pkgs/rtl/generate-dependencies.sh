#!/usr/bin/env bash

node2nix \
  --nodejs-12 \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix
