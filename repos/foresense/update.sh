#!/usr/bin/env bash
# Wrapper around nix-update encoding the per-package knowledge of this repo.
#
# Usage:
#   ./update.sh              update all release-tracked packages (convert-with-moss,
#                            sektron, signls, serialosc)
#   ./update.sh <attrs...>   pass attrs straight through to nix-update
#                            (e.g. ./update.sh libmts utu)
#
# Notes:
# - GitHub-release-tracked packages (out-of-the-box nix-update support):
#   convert-with-moss, sektron, signls, serialosc
# - Pinned-rev packages: libmts, utu. Updatable via
#   `nix-update --version=branch <attr>`, but the build may need manual fixing
#   afterwards (utu's pin exists precisely because newer upstream broke it).
# - Loomer packages (architect, aspect, manifold, resound, sequent, shift,
#   string) are deliberately NOT touched: Loomer is out of business, there will
#   be no more upstream releases, and their fetchurl/S3 hashes are frozen.
#
# nix-update is expected from PATH; use `nix develop` or run via ./update.sh
# inside the dev shell so it is available.
set -u

cd "$(dirname "$0")"

extra_flags=()
attrs=()
# Known attrs that follow upstream GitHub releases (nix-update handles natively).
default_attrs=(convert-with-moss sektron signls serialosc)

for arg in "$@"; do
  case "$arg" in
    -*) extra_flags+=("$arg") ;;
    *) attrs+=("$arg") ;;
  esac
done

failures=0
summary=()

run_update() {
  local attr="$1"
  echo "=== nix-update ${extra_flags[*]} $attr"
  if nix-update "${extra_flags[@]}" "$attr"; then
    summary+=("OK: $attr")
  else
    summary+=("FAILED: $attr")
    failures=$((failures + 1))
  fi
}

if [ "${#attrs[@]}" -gt 0 ]; then
  for attr in "${attrs[@]}"; do
    run_update "$attr"
  done
else
  for attr in "${default_attrs[@]}"; do
    run_update "$attr"
  done
fi

echo
echo "=== Summary"
printf '%s\n' "${summary[@]}"

echo
echo "Remember to build updated packages locally before pushing:"
echo "  nix build .#<updated-attr>   (or ./update.sh --commit && nix build ...)"
echo "CI builds are the safety net, but a local check avoids red CI."

exit "$failures"
