#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

node2nix \
  --input node-packages.json \
  --output node-packages.nix \
  --composition node-composition.nix \
  --development # See https://github.com/svanderburg/node2nix/issues/149
