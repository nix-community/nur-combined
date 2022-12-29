#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

cd "$(dirname $(readlink -f $0))"

node2nix \
  --nodejs-16 \
  --node-env node-env.nix \
  --input node-packages.json \
  --output node-packages.nix \
  --composition node-composition.nix
