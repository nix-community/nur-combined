#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq php.packages.composer nix-update coreutils
# shellcheck shell=bash

set -eou pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf -- "${TMPDIR}"' EXIT

git clone --depth 1 --branch "${GIT_VERSION}" https://github.com/shlinkio/shlink.git "${TMPDIR}/shlink"
composer -d "${TMPDIR}/shlink" install
cp "${TMPDIR}/shlink/composer.lock" "pkgs/by-name/sh/shlink/composer.lock"

nix-update shlink --version=skip
