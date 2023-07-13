#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

tag="v5.1.1"
u="https://gitlab.com/matsievskiysv/math-preview/-/raw/$tag"
# Download package.json and patch in @discordjs/opus optional dependency
curl $u/package.json > package.json

node2nix \
  --input package.json \
  --strip-optional-dependencies \
  --output node-packages.nix \
  --composition node-composition.nix \
  --registry https://registry.npmjs.org \
  --registry https://gitlab.com/api/v4/packages/npm
  # --node-env ../../development/node-packages/node-env.nix \

# sed -i 's|<nixpkgs>|../../..|' node-composition.nix

rm -f package.json
