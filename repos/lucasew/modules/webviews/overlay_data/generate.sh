#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix nodejs

node2nix -i ./packages.json -o packages.nix -c composition.nix