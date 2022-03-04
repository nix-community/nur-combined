#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

node2nix -i node-packages.json -c n2n-default.nix
