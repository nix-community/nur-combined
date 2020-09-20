##!/usr/bin/env nix-shell
##! nix-shell -i bash -p nodePackages.node2nix

# FIXME: node-env to relative path when officially packaged
node2nix \
  --nodejs-13 \
  --node-env node-env.nix \
  --development \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix

