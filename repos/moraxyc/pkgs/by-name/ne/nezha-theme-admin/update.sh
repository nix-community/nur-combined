#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl coreutils nodejs
# shellcheck shell=bash

set -eou pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf -- "${TMPDIR}"' EXIT

cp "$(nix --experimental-features "nix-command flakes" build .#sources.nezha-theme-admin.extract.'"package-lock.json"' --no-link --print-out-paths)" "$TMPDIR"/package-lock.json
chmod u+w "$TMPDIR"/package-lock.json
pushd "$TMPDIR"
npx -y npm-package-lock-add-resolved
popd
cp "$TMPDIR"/package-lock.json pkgs/by-name/ne/nezha-theme-admin/package-lock.json
