#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git nix-prefetch-git
set -euo pipefail

URL_BASE=https://evilpiepirate.org/git/bcachefs.git

cd "$(dirname "${BASH_SOURCE[0]}")"

COMMIT=$(git ls-remote $URL_BASE HEAD | awk '{ print $1; }')
rm -f version.json

echo $COMMIT
VERSION=$(cat ../../VERSION)
if [ $(cat ../../REBASE_BROKEN) = "yes" ]; then
    nix-prefetch-git $URL_BASE $COMMIT > version.json
fi

URL="$URL_BASE/rawdiff/?id=${COMMIT}&id2=v${VERSION}"
diffHash=$(nix-prefetch-url $URL --name bcachefs-${COMMIT}.diff)

echo $diffHash
sed -i "s/commit = \"\([a-z0-9]*\)\";/commit = \"${COMMIT}\";/" default.nix
sed -i "s/diffHash = \"\([a-z0-9]*\)\";/diffHash = \"${diffHash}\";/" default.nix
