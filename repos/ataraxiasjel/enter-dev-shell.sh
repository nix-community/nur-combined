#!/usr/bin/env bash

set -x
set -euo pipefail

DEVENV_ROOT_FILE="$(mktemp)"
printf %s "$PWD" > "$DEVENV_ROOT_FILE"
nix develop --accept-flake-config --override-input devenv-root "file+file://$DEVENV_ROOT_FILE" .#dev --command bash -c "${@}"