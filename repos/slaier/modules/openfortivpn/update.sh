#!/usr/bin/env bash

set -euo pipefail

image=ghcr.io/slaier/openfortivpn
tag=latest
attr='(import ./source.nix)'

oldVersion=$(nix-instantiate --eval --expr "$attr.imageDigest" | tr -d '"')
newVersion=$(docker manifest inspect $image:$tag |
    jq -r '.manifests | .[] | select(.platform.architecture == "arm64") | .digest')

if [[ "$oldVersion" == "$newVersion" ]]; then
    echo "$image is up-to-date: $oldVersion" >&2
    exit 0
fi

tmp=$(mktemp)
nix-prefetch-docker --os linux --arch arm64 --image-name $image --image-digest "$newVersion" > "$tmp"
mv "$tmp" source.nix

echo "$image: $oldVersion -> $newVersion"
