#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

node2nix \
  --node-env ./node-env.nix \
  --lock _package-lock.json \
  --output node-packages.nix \
  --composition node-composition.nix
