#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix git

set -e

TAG=$(git ls-remote --tags git://github.com/kalkih/mini-graph-card.git | tail -n1  | awk -F/ '{ print $3 }')

sed -i "s/#.*\"/#${TAG}\"/" package.json 

node2nix \
  --nodejs-12 \
  --development \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix

