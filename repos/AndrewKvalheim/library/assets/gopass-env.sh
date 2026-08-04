#!/usr/bin/env bash
set -Eeuo pipefail

readonly path="$1"

eval "$(gopass-await "$path" 'env')"
exec "${@:2}"
