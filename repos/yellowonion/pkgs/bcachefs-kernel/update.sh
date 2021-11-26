#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

COMMIT=$(git ls-remote https://evilpiepirate.org/git/bcachefs.git HEAD | awk '{ print $1; }')

echo $COMMIT

sed -i "s/commit = \"\([a-z0-9]*\)\";/commit = \"${COMMIT}\";/" default.nix
sed -i "s/diffHash = \"\([a-z0-9]*\)\";/diffHash = lib.fakeSha256;/" default.nix
