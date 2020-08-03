#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix git

set -e

OWNER=kalkih
REPO=mini-graph-card
TAG=$(curl https://api.github.com/repos/$OWNER/$REPO/releases/latest | jq -r '.tag_name')

sed -i "s/#.*\"/#${TAG}\"/" package.json

node2nix \
  --nodejs-12 \
  --development \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix

