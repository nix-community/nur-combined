#!/usr/bin/env bash

set -euo pipefail

name=safeeyes
attr="with import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; }; $name"
oldVersion=$(nix-instantiate --eval --expr "$attr.version" | tr -d '"')
newVersion=$(curl -s "https://pypi.org/pypi/$name/json" | jq -r '.info.version')

if [[ "$oldVersion" == "$newVersion" ]]; then
    echo "$name is up-to-date: $oldVersion" >&2
    exit 0
fi

oldVersionEscaped=$(echo "$oldVersion" | sed -re 's|[.+]|\\&|g')

oldHash=$(nix-instantiate --eval --expr "$attr.src.drvAttrs.outputHash" | tr -d '"' | sed -re 's|[+]|\\&|g')
newHash=$(nix-prefetch-url "https://pypi.org/packages/source/s/$name/$name-$newVersion.tar.gz" 2>/dev/null | xargs nix hash to-sri --type sha256)

sed -i overlay.nix -r -e "/\bversion\b\s*=/ s|\"$oldVersionEscaped\"|\"$newVersion\"|" -e "s|\"$oldHash\"|\"$newHash\"|"
echo "$name: $oldVersion -> $newVersion"
