#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git gnugrep gnused nix-update coreutils pnpm nodejs
# shellcheck shell=bash

set -euo pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf -- "${TMPDIR}"' EXIT

cp -r "$(nix-build -A clash-nyanpasu.src --no-out-link)" "${TMPDIR}/clash-nyanpasu"
chmod -R u+w "${TMPDIR}/clash-nyanpasu"

pushd "${TMPDIR}/clash-nyanpasu" >/dev/null

settings=frontend/nyanpasu/project.inlang/settings.json
inlang_cdn='"https://cdn\.jsdelivr\.net/npm/(@inlang/[^@"]+)@([^/"]+)/dist/index\.js"'

git init -q
git add frontend/nyanpasu/package.json "$settings" pnpm-lock.yaml
git -c user.name=tmp -c user.email=tmp@example.invalid commit -qm init

mapfile -t inlang_plugins < <(
  grep -oE "$inlang_cdn" "$settings" \
    | sed -E "s#$inlang_cdn#\1@\2#" \
    | awk '!seen[$0]++'
)

sed -i -E "s#$inlang_cdn#\"./node_modules/\1/dist/index.js\"#g" "$settings"

pnpm --filter @nyanpasu/nyanpasu add -D \
  "${inlang_plugins[@]}" \
  --lockfile-only

git diff --no-ext-diff HEAD -- \
  frontend/nyanpasu/package.json \
  "$settings" \
  pnpm-lock.yaml \
  > fix-local-inlang-plugins.patch

popd >/dev/null

mv "${TMPDIR}/clash-nyanpasu/fix-local-inlang-plugins.patch" \
  "pkgs/by-name/cl/clash-nyanpasu/"

nix-update clash-nyanpasu.pnpmDeps --version=skip
