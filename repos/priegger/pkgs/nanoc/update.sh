#!/usr/bin/env nix-shell
#!nix-shell -i bash -I nixpkgs=https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz -p bundix nixpkgs-fmt

set -o errexit
set -o nounset

rm -f Gemfile.lock gemset.nix
bundix --magic
rm -rf .bundle vendor

nixpkgs-fmt .
