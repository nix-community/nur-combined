#!/usr/bin/env bash

set -euo pipefail

owner=QNetITQ
repo=WaveFox
name=wavefox

oldVersion=$(nix eval --raw ".#$name.version" 2>/dev/null)
newVersion=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r '.tag_name[1:]')

if [[ "$oldVersion" == "$newVersion" ]]; then
    echo "$name is up-to-date: $oldVersion" >&2
    exit 0
fi

oldVersionEscaped=$(echo "$oldVersion" | sed -re 's|[.+]|\\&|g')

oldHash=$(nix eval --raw ".#$name.src.outputHash" 2>/dev/null | sed -re 's|[+]|\\&|g')
newHash=$(nix flake prefetch --json "github:$owner/$repo/v$newVersion" | jq -r '.hash')

sed -i package.nix -r -e "/\bversion\b\s*=/ s|\"$oldVersionEscaped\"|\"$newVersion\"|" -e "s|\"$oldHash\"|\"$newHash\"|"
echo "$name: $oldVersion -> $newVersion"
