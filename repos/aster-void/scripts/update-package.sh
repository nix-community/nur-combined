#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec deno run --allow-all "$SCRIPT_DIR/update-package/main.ts" "$@"
