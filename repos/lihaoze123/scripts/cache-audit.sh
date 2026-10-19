#!/usr/bin/env bash
set -euo pipefail
umask 077

[[ $# == 1 && -s $1 ]] || { echo "Usage: cache-audit.sh OUTPUT_PATHS_FILE" >&2; exit 2; }
: "${ATTIC_TOKEN:?}"
audit_temp=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/nur-cache-audit.XXXXXX")
cleanup() {
  local audit_status=$?
  # Imported store directories are read-only, including in a user-owned store.
  chmod -R u+w -- "$audit_temp"
  rm -rf -- "$audit_temp"
  return "$audit_status"
}
trap cleanup EXIT
printf 'machine cache.chumeng.xyz login attic password %s\n' "$ATTIC_TOKEN" > "$audit_temp/netrc"
unset ATTIC_TOKEN
mapfile -t audit_paths < "$1"
audit_store="local?root=$audit_temp/store"

# Output paths only: there are no derivations in this new store to rebuild.
# Disable builders so an incomplete cache is reported as a failure.
nix-store --store "$audit_store" --realise "${audit_paths[@]}" \
  --option substituters 'https://cache.chumeng.xyz/nur https://cache.nixos.org' \
  --option extra-substituters '' \
  --option trusted-public-keys 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nur:dJh05Op2+iv3GCHoaF2+1FfQtqcUZzf/4v/ZTaLHomY=' \
  --option extra-trusted-public-keys '' \
  --option netrc-file "$audit_temp/netrc" \
  --option build-users-group '' --option builders '' --option max-jobs 0 \
  --option narinfo-cache-negative-ttl 0 --option require-sigs true
nix store verify --store "$audit_store" --recursive "${audit_paths[@]}" \
  --option trusted-public-keys 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nur:dJh05Op2+iv3GCHoaF2+1FfQtqcUZzf/4v/ZTaLHomY='
echo "Verified all runtime closures from an initially empty store."
