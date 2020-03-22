#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bundix nixpkgs-fmt

set -o errexit
set -o nounset

rm -f Gemfile.lock gemset.nix
bundix --magic
rm -rf .bundle vendor

nixpkgs-fmt .
