#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq php.packages.composer nix-update coreutils
# shellcheck shell=bash

set -eou pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf -- "${TMPDIR}"' EXIT

cp -r "$(nix-build -A shlink.src --no-out-link)" "${TMPDIR}/shlink"
chmod -R u+w "${TMPDIR}/shlink"
composer -d "${TMPDIR}/shlink" install
cp "${TMPDIR}/shlink/composer.lock" "pkgs/by-name/sh/shlink/composer.lock"

nix-update shlink --version=skip
