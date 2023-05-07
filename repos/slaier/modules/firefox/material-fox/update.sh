#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq git

set -euo pipefail

owner=muckSponge
repo=MaterialFox
name=material-fox

oldVersion=$(nix eval --raw ".#$name.version" 2>/dev/null)
newVersion=$(git ls-remote --tags --refs "https://github.com/$owner/$repo" | tail -n1 | cut --delimiter=/ --field=3- | sed -re 's|^v||')

if [[ "$oldVersion" == "$newVersion" ]]; then
    echo "$name is up-to-date: $oldVersion" >&2
    exit 0
fi

oldVersionEscaped=$(echo "$oldVersion" | sed -re 's|[.+]|\\&|g')

oldHash=$(nix eval --raw ".#$name.src.outputHash" 2>/dev/null | sed -re 's|[+]|\\&|g')
newHash=$(nix flake prefetch --json "github:$owner/$repo/v$newVersion" | jq -r '.hash')

sed -i package.nix -r -e "/\bversion\b\s*=/ s|\"$oldVersionEscaped\"|\"$newVersion\"|" -e "s|\"$oldHash\"|\"$newHash\"|"
echo "$name: $oldVersion -> $newVersion"
