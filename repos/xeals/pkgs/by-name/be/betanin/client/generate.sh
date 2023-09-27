#!/usr/bin/env bash

# Requires node2nix and jq

cd "$(dirname "$0")" || exit 1

set -euo pipefail

nix build ..#betanin.src 2>/dev/null

tempDir=$(mktemp -d)
cp result/betanin_client/package.json "$tempDir/"
cp result/betanin_client/package-lock.json "$tempDir/"
pushd "$tempDir"

node2nix \
    --input package.json \
    --lock package-lock.json \
    --output packages.nix \
    --composition composition.nix \
    --strip-optional-dependencies \
    --development \
    --nodejs-18

popd
cp "$tempDir"/*.nix .

rm result
rm -rf "$tempDir"
