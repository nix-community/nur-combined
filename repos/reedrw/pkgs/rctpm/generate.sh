#!/usr/bin/env nix-shell
#!nix-shell -i bash -p wget yarn2nix

set -euo pipefail

if [ "$#" -ne 1 ] || [[ "$1" == -* ]]; then
  echo "Regenerates the Yarn dependency lock files for the rctpm package."
  echo "Usage: $0 <git release tag>"
  exit 1
fi

SRC_REPO="https://raw.githubusercontent.com/tubbo/rctpm/$1"

wget "$SRC_REPO/package.json" -O package.json
wget "$SRC_REPO/yarn.lock" -O yarn.lock
yarn2nix --lockfile=yarn.lock > yarn-dependencies.nix
rm yarn.lock
