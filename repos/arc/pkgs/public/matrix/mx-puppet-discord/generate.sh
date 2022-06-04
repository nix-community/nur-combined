#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

rev=376221474c2cfc655370503f4716b7e7307f75a7
u=https://raw.githubusercontent.com/NicolasDerumigny/mx-puppet-discord/$rev
curl -O $u/package.json
curl $u/package-lock.json |
  sed -e 's|git+ssh://git@|git+https://|g' > package-lock.json

node2nix \
  --nodejs-14 \
  --input package.json \
  --lock package-lock.json \
  --output node-packages.nix \
  --composition node-composition.nix

rm -f package.json package-lock.json node-composition.nix
