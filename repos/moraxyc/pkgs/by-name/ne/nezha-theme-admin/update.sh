#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl coreutils nodejs
# shellcheck shell=bash

set -eou pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf -- "${TMPDIR}"' EXIT

curl -L -o "$TMPDIR"/fixup-package-lock.mjs https://gist.github.com/Moraxyc/72f1bca35685f9ede9cf0fb4c0d343c5/raw/797744edb3df0a36282ddeeb0c7b5fa1fe177712/fixup-package-lock.mjs
cp "$(nix --experimental-features "nix-command flakes" build .#sources.nezha-theme-admin.extract.'"package-lock.json"' --no-link --print-out-paths)" "$TMPDIR"/package-lock.json
chmod u+w "$TMPDIR"/package-lock.json
node "$TMPDIR"/fixup-package-lock.mjs "$TMPDIR"/package-lock.json
cp "$TMPDIR"/package-lock.json pkgs/by-name/ne/nezha-theme-admin/package-lock.json
