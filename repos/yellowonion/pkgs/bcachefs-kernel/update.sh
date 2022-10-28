#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

COMMIT=$(git ls-remote https://evilpiepirate.org/git/bcachefs.git HEAD | awk '{ print $1; }')

echo $COMMIT
VERSION="6.0"
URL="https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${COMMIT}&id2=v${VERSION}"
diffHash=$(nix-prefetch-url $URL --name bcachefs-${COMMIT}.diff)
echo $diffHash
sed -i "s/commit = \"\([a-z0-9]*\)\";/commit = \"${COMMIT}\";/" default.nix
sed -i "s/diffHash = \"\([a-z0-9]*\)\";/diffHash = \"${diffHash}\";/" default.nix
