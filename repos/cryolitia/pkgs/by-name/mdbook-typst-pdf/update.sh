#!/usr/bin/env -S nix shell nixpkgs#nix nixpkgs#curl nixpkgs#jq nixpkgs#nix-prefetch-github nixpkgs#curl --command bash

set -euo pipefail

directory="$(dirname $0 | xargs realpath)"

version="$(curl "https://api.github.com/repos/KaiserY/mdbook-typst-pdf/releases?per_page=1" | jq -r '.[0].tag_name')"

hash=$(nix-prefetch-github KaiserY mdbook-typst-pdf --rev ${version} -v | jq -r .hash)

curl https://raw.githubusercontent.com/KaiserY/mdbook-typst-pdf/${version}/Cargo.lock -o $directory/Cargo.lock

cat > $directory/pin.json << EOF
{
  "version": "${version#*v}",
  "hash": "$hash"
}
EOF

cat $directory/pin.json
