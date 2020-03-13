#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bundix

set -o errexit
set -o nounset

rm -f Gemfile.lock gemset.nix
bundix --magic
rm -rf .bundle vendor
