#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

node2nix \
  --input package.json \
  --lock package-lock.json \
  --output node-packages.nix \
  --composition node-composition.nix \
  --node-env ../../../node-packages/node-env.nix
