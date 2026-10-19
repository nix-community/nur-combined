#!/usr/bin/env bash
set -euo pipefail
umask 077

if [[ $# != 1 ]]; then
  echo "Usage: cache-attic.sh OUTPUT_PATHS_FILE" >&2
  exit 2
fi
: "${ATTIC_TOKEN:?}"
cache_endpoint=${ATTIC_ENDPOINT:-https://cache.chumeng.xyz/}
cache_temp=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/nur-attic.XXXXXX")
trap 'rm -rf -- "$cache_temp"' EXIT
mkdir -p "$cache_temp/attic"
printf '%s\n' "$ATTIC_TOKEN" > "$cache_temp/token"
unset ATTIC_TOKEN
cat > "$cache_temp/attic/config.toml" <<EOF
default-server = "ci"
[servers.ci]
endpoint = "$cache_endpoint"
token-file = "$cache_temp/token"
EOF
if [[ ! -s $1 ]]; then
  echo "No outputs to cache."
  exit 0
fi
XDG_CONFIG_HOME="$cache_temp" attic push ci:nur --stdin --jobs 4 < "$1"
# Every explicitly exported output is a private-cache target. Only its public
# dependencies may be omitted by Attic's upstream cache filter.
XDG_CONFIG_HOME="$cache_temp" attic push ci:nur --stdin --jobs 4 \
  --no-closure --ignore-upstream-cache-filter < "$1"
ATTIC_TOKEN_FILE="$cache_temp/token" python3 scripts/cache_metadata.py "$1"
echo "Published runtime closures to the private Attic cache."
