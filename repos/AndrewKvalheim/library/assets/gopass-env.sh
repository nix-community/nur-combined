#!/usr/bin/env bash
set -Eeuo pipefail

path="$1"
shift

eval "$(gopass-await "$path" env)"

exec "$@"
