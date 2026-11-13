#!/usr/bin/env bash

set -euo pipefail

cd "${FETCHRIX_SOURCE:?}"

settings=frontend/nyanpasu/project.inlang/settings.json
inlang_cdn='"https://cdn\.jsdelivr\.net/npm/(@inlang/[^@"]+)@([^/"]+)/dist/index\.js"'

mapfile -t inlang_plugins < <(
  grep -oE "$inlang_cdn" "$settings" \
    | sed -E "s#$inlang_cdn#\1@\2#" \
    | awk '!seen[$0]++'
)

if [ "${#inlang_plugins[@]}" -eq 0 ]; then
  echo "No inlang CDN plugins found in $settings" >&2
  exit 1
fi

sed -i -E "s#$inlang_cdn#\"./node_modules/\1/dist/index.js\"#g" "$settings"

export pnpm_config_pm_on_fail=ignore
pnpm --filter @nyanpasu/nyanpasu add -D \
  "${inlang_plugins[@]}" \
  --lockfile-only --ignore-scripts
