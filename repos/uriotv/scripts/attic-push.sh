#!/usr/bin/env bash
# Push store paths to the private attic cache, next to (never instead of) cachix.
# Usage: attic-push.sh PATH_LIST_FILE
# Requires the attic client on PATH. ATTIC_TOKEN is read from the environment only:
# it is never printed, written to the repository, or passed on a command line
# other than the one `attic login` requires.
set -euo pipefail

list=${1:?Usage: attic-push.sh PATH_LIST_FILE}
endpoint=https://attic.urio.dev
cache=urio

if [[ -z "${ATTIC_TOKEN:-}" ]]; then
  msg="attic push skipped: ATTIC_TOKEN is not set. Cachix publication is unaffected; the private cache is not updated."
  echo "::warning::${msg}"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then printf '\n> [!WARNING]\n> %s\n' "$msg" >> "$GITHUB_STEP_SUMMARY"; fi
  exit 0
fi

if [[ ! -s "$list" ]]; then
  echo 'attic push: nothing to push (empty path list)'
  exit 0
fi

# Validate every line before any network call: only absolute store paths.
mapfile -t paths < "$list"
for path in "${paths[@]}"; do
  [[ "$path" =~ ^/nix/store/[0-9a-z]{32}-[^[:space:]/]+$ ]] || {
    echo "::error::attic push refused a non-store path"
    exit 1
  }
done

# Isolated client configuration; removed on exit, so no token file survives.
config_home=$(mktemp -d)
trap 'rm -rf "$config_home"' EXIT
export XDG_CONFIG_HOME="$config_home"

attic login "$cache" "$endpoint" "$ATTIC_TOKEN" > /dev/null
attic push "$cache" "${paths[@]}"

echo "attic push: ${#paths[@]} path(s) pushed to ${endpoint}/${cache} (closure included by attic push)."
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf '\n## attic push\n\n%s path(s) pushed to the private cache %s.\n' "${#paths[@]}" "$cache" >> "$GITHUB_STEP_SUMMARY"
fi
