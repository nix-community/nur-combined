#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

set -euo pipefail

owner=arkenfox
repo=user.js
name=$owner-userjs

oldVersion=$(nix eval --raw ".#$name.version" 2>/dev/null)
newVersion=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r '.tag_name')

if [[ "$oldVersion" == "$newVersion" ]]; then
    echo "$name is up-to-date: $oldVersion" >&2
    exit 0
fi

oldVersionEscaped=$(echo "$oldVersion" | sed -re 's|[.+]|\\&|g')

oldHash=$(nix eval --raw ".#$name.outputHash" 2>/dev/null | sed -re 's|[+]|\\&|g')
newHash=$(nix-prefetch-url "https://raw.githubusercontent.com/${owner}/${repo}/${newVersion}/user.js" 2>/dev/null | xargs nix hash to-sri --type sha256)

sed -i package.nix -r -e "/\bversion\b\s*=/ s|\"$oldVersionEscaped\"|\"$newVersion\"|" -e "s|\"$oldHash\"|\"$newHash\"|"
echo "$name: $oldVersion -> $newVersion"
