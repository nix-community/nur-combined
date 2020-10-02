#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure
set -e

unset SSL_CERT_FILE
unset NIX_SSL_CERT_FILE

rm -f \
   default.nix \
   node-packages.nix \
   node-env.nix

rm -rf tmp

mkdir tmp
patch -o tmp/package.json $src/package.json missing-deps.patch

node2nix \
  --development \
  --input tmp/package.json

rm -rf tmp
