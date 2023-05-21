#!/usr/bin/env bash

set -euo pipefail

owner=pymumu
repo=smartdns
attr="with import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; }; $repo"
oldVersion=$(nix-instantiate --eval --expr "$attr.version" | tr -d '"')
newVersion=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r '.tag_name[7:]')

if [[ "$oldVersion" == "$newVersion" ]]; then
    echo "$repo is up-to-date: $oldVersion" >&2
    exit 0
fi

oldVersionEscaped=$(echo "$oldVersion" | sed -re 's|[.+]|\\&|g')

oldHash=$(nix-instantiate --eval --expr "$attr.src.drvAttrs.outputHash" | tr -d '"' | sed -re 's|[+]|\\&|g')
newHash=$(nix flake prefetch --json "github:$owner/$repo/Release$newVersion" | jq -r '.hash')

sed -i overlay.nix -r -e "/\bversion\b\s*=/ s|\"$oldVersionEscaped\"|\"$newVersion\"|" -e "s|\"$oldHash\"|\"$newHash\"|"
echo "$repo: $oldVersion -> $newVersion"
