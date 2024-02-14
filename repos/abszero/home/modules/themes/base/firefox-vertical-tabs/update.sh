#! /usr/bin/env nix-shell
#! nix-shell update-shell.nix -i bash

set -eou pipefail

ROOT="$(dirname "$(readlink -f "$0")")"

nix-prefetch-github --json ranmaru22 firefox-vertical-tabs > "$ROOT/lock.json"
