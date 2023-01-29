#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

rev=785d0a0f8def8c7a404d3ba7dea552e1e4cb55ce
u=https://gitlab.com/ruslang02/mx-puppet-discord/-/raw/$rev
curl $u/package.json |
  sed 's|"typescript": *"\^\?3\.[^"]*"|"typescript": "^4.8.3"|' |  # TODO: remove when newer typescript version pinned
  sed 's|\("dependencies": *{\)|\1\n"@discordjs/opus": "^0.8.0",|' >package.json

node2nix \
  --nodejs-14 \
  --input package.json \
  --output node-packages.nix \
  --composition node-composition.nix \
  --strip-optional-dependencies \
  --registry https://registry.npmjs.org \
  --registry https://gitlab.com/api/v4/packages/npm \
  --registry-scope '@mx-puppet'

rm -f package.json package-lock.json node-composition.nix node-env.nix
