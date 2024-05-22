#!/usr/bin/env -S nix shell nixpkgs#nix nixpkgs#curl nixpkgs#jq nixpkgs#nix-prefetch-github nixpkgs#curl --command bash

set -euo pipefail

directory="$(dirname $0 | xargs realpath)"

version_beta="$(curl "https://api.github.com/repos/MaaAssistantArknights/MaaAssistantArknights/releases?per_page=1" | jq -r '.[0].tag_name')"

hash_beta=$(nix-prefetch-github MaaAssistantArknights MaaAssistantArknights --fetch-submodules --rev ${version_beta} -v | jq -r .hash)

version_cli="$(curl "https://api.github.com/repos/MaaAssistantArknights/maa-cli/releases?per_page=1" | jq -r '.[0].tag_name')"

rev_cli="$(curl "https://api.github.com/repos/MaaAssistantArknights/maa-cli/git/ref/tags/${version_cli}" | jq -r '.object.sha')"

name_cli="$(curl "https://api.github.com/repos/MaaAssistantArknights/maa-cli/releases?per_page=1" | jq -r '.[0].name')"

hash_cli=$(nix-prefetch-github MaaAssistantArknights maa-cli --rev ${rev_cli} -v | jq -r .hash)

cargo_hash_cli=$(nix store prefetch-file --json https://raw.githubusercontent.com/MaaAssistantArknights/maa-cli/${rev_cli}/Cargo.lock | jq -r .hash)

curl https://raw.githubusercontent.com/MaaAssistantArknights/maa-cli/${rev_cli}/Cargo.lock -o $directory/Cargo.lock

cat > $directory/pin.json << EOF
{
  "beta": {
    "version": "${version_beta#*v}",
    "hash": "$hash_beta"
  },
  "maa-cli": {
    "name": "${name_cli#*v}",
    "version": "$rev_cli",
    "hash": "$hash_cli",
    "cargoHash": "$cargo_hash_cli"
  }
}
EOF

cat $directory/pin.json
