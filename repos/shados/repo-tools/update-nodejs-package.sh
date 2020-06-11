#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash nodePackages.node2nix

node2nix --nodejs-12 -d -i node-packages.json -c package.nix

# vim: set ft=sh :
