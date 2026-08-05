#!/usr/bin/env bash
# Bump sentry. nix-update alone is not enough: the build also pins the
# @sentry/api version from upstream's pnpm-lock.yaml and the matching
# sentry-api-schema spec, which move independently of the CLI version.
# Usage: ./update.sh [--commit]
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"
nix_file=pkgs/sentry/default.nix

old_version="$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$nix_file")"
nix-shell -p nix-update --run "nix-update sentry"
new_version="$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$nix_file")"

# nix-update already fixed up src/pnpmDeps hashes, so src evaluates cleanly here
src="$(nix build .#sentry.src --no-link --print-out-paths)"
new_api="$(sed -n "s|^  '@sentry/api@\([0-9.]*\)':$|\1|p" "$src/pnpm-lock.yaml" | head -n1)"
if [ -z "$new_api" ]; then
  echo "error: could not read @sentry/api version from $src/pnpm-lock.yaml" >&2
  exit 1
fi

old_api="$(sed -n 's/^  sentryApiVersion = "\(.*\)";$/\1/p' "$nix_file")"
if [ "$new_api" != "$old_api" ]; then
  url="https://raw.githubusercontent.com/getsentry/sentry-api-schema/${new_api}/openapi-derefed.json"
  sri="$(nix store prefetch-file --json "$url" | jq -r .hash)"
  # the spec hash is the line right after the sentry-api-schema url
  sed -i.bak \
    -e 's|^  sentryApiVersion = ".*";|  sentryApiVersion = "'"$new_api"'";|' \
    -e '\|sentry-api-schema|,+1 s|hash = "sha256-[^"]*"|hash = "'"$sri"'"|' \
    "$nix_file"
  rm -f "$nix_file.bak"
  echo "sentry: @sentry/api $old_api -> $new_api"
fi

if [ "$new_version" != "$old_version" ]; then
  subject="sentry: $old_version -> $new_version"
elif [ "$new_api" != "$old_api" ]; then
  subject="sentry: re-pin @sentry/api $old_api -> $new_api"
else
  echo "sentry is up to date: $old_version"
  exit 0
fi
echo "$subject"

if [ "${1:-}" = "--commit" ] && ! git diff --quiet -- "$nix_file"; then
  git commit -m "$subject" -- "$nix_file"
fi
