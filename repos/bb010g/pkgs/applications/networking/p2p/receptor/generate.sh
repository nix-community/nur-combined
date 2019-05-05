#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure --keep NIX_PATH -p nodePackages.node2nix -p nix -p git
set -ueo pipefail
typeset nixpkgs
nixpkgs=$(nix-instantiate --eval -E '<nixpkgs>')
node2nix -8 -i pkg.json -d -o node-packages-dev.nix -c node-dev.nix \
  -e "$nixpkgs"/pkgs/development/node-packages/node-env.nix --no-copy-node-env
sed -i node-dev.nix \
  -e 's#\(import \).*\(/pkgs/development/node-packages/node-env.nix\)#\1(pkgs.path + "\2")#g'
