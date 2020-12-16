#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix
node2nix --nodejs-14 -i node-packages.json -o node-packages.nix -c composition.nix
