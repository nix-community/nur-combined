#!/usr/bin/env bash

set -euo pipefail

owner=cattyhouse
repo=new-uboot-for-N1
name=uboot-phicomm-n1

oldVersion=$(nix eval --raw ".#$name.version" 2>/dev/null)
head=$(curl -s https://api.github.com/repos/$owner/$repo/commits/HEAD)
newVersion=unstable-$(jq -r ".commit.committer.date[0:10]" <<< "$head")

if [[ "$oldVersion" == "$newVersion" ]]; then
    echo "$name is up-to-date: $oldVersion" >&2
    exit 0
fi

oldRev=$(nix eval --raw ".#$name.src.rev" 2>/dev/null)
newRev=$(jq -r ".sha" <<< "$head")

oldHash=$(nix eval --raw ".#$name.src.outputHash" 2>/dev/null | sed -re 's|[+]|\\&|g')
newHash=$(nix flake prefetch --json "github:$owner/$repo/$newRev" | jq -r '.hash')

sed -i package.nix -r -e "/\bversion\b\s*=/ s|\"$oldVersion\"|\"$newVersion\"|" -e "s|\"$oldRev\"|\"$newRev\"|"  -e "s|\"$oldHash\"|\"$newHash\"|"
echo "$name: $oldVersion -> $newVersion"
