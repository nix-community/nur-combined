#!/usr/bin/env bash
set -euo pipefail
repo="$(readlink -f -- "$(dirname -- "$0")")"
nix build "$repo"#generated --out-link "$repo"/.generated "$@"
