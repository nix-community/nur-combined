#!/usr/bin/env bash

if [ -n "$GITHUB_TOKEN" ]; then
    TOKEN_ARGS=(--header "Authorization: token $GITHUB_TOKEN")
fi

if [[ $# -gt 1 || $1 == -* ]]; then
    echo "Regenerates packaging data for the autobrr packages."
    echo "Usage: $0 [git release tag]"
    exit 1
fi

set -x

cd "$(dirname "$0")"
version="$1"

set -euo pipefail

if [ -z "$version" ]; then
    version="$(wget -O- "${TOKEN_ARGS[@]}" "https://api.github.com/repos/autobrr/autobrr/releases?per_page=1" | jq -r '.[0].tag_name')"
fi

# strip leading "v"
version="${version#v}"

# Autobrr repository
src_hash=$(nix-prefetch-github autobrr autobrr --rev "v${version}" | jq -r .hash)

# Frontend dependencies
autobrr_src="https://raw.githubusercontent.com/autobrr/autobrr/v$version"
wget "${TOKEN_ARGS[@]}" "$autobrr_src/web/package.json" -O package.json

trap 'rm -rf pnpm-lock.yaml' EXIT
wget "${TOKEN_ARGS[@]}" "$autobrr_src/web/pnpm-lock.yaml"
pnpm-lock-export --schema yarn.lock@v1
yarn_hash=$(prefetch-yarn-deps yarn.lock)

# Use friendlier hashes
src_hash=$(nix hash to-sri --type sha256 "$src_hash")
yarn_hash=$(nix hash to-sri --type sha256 "$yarn_hash")

sed -i -E -e "0#version#s#version = \".*\"#version = \"$version\"#" default.nix
sed -i -E -e "s#srcHash = \".*\"#srcHash = \"$src_hash\"#" default.nix
sed -i -E -e "s#yarnHash = \".*\"#yarnHash = \"$yarn_hash\"#" default.nix
