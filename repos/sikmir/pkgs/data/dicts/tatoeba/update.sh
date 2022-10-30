#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils curl gnused nix-prefetch jq

set -euo pipefail
cd "$(dirname "$0")"

# The files are updated every Saturday at 6:30 AM (UTC).
version=`date -u -d "-$(( $(date -u +%w) + 1 )) days" +%Y-%m-%d`

sed -i "s/version = \".*\"/version = \"$version\"/" default.nix

cat tatoeba.json | jq -r '.[]|.url,.hash' | paste - - | while read -r url hash; do
    newHash=$(nix-prefetch-url --type sha256 $url)
    sriHash="$(nix hash to-sri --type sha256 $newHash)"
    sed -i "s#$hash#$sriHash#" tatoeba.json
done
