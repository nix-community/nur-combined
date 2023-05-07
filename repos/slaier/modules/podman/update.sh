#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq git

set -euo pipefail

owner=containers
repo=podman-compose
attr="with import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; }; $repo"
oldVersion=$(nix-instantiate --eval --expr "$attr.version" | tr -d '"')
newVersion=$(git ls-remote --tags --refs "https://github.com/$owner/$repo" | tail -n1 | cut --delimiter=/ --field=3- | sed -re 's|^v||')

if [[ "$oldVersion" == "$newVersion" ]]; then
    echo "$repo is up-to-date: $oldVersion" >&2
    exit 0
fi

oldVersionEscaped=$(echo "$oldVersion" | sed -re 's|[.+]|\\&|g')

oldHash=$(nix-instantiate --eval --expr "$attr.src.drvAttrs.outputHash" | tr -d '"' | sed -re 's|[+]|\\&|g')
newHash=$(nix flake prefetch --json "github:$owner/$repo/v$newVersion" | jq -r '.hash')

sed -i overlay.nix -r -e "/\bversion\b\s*=/ s|\"$oldVersionEscaped\"|\"$newVersion\"|" -e "s|\"$oldHash\"|\"$newHash\"|"
echo "$repo: $oldVersion -> $newVersion"
