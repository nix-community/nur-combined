#! /usr/bin/env nix-shell
#! nix-shell update-shell.nix -i bash

set -eou pipefail

ROOT="$(dirname "$(readlink -f "$0")")"

nix-prefetch-git https://codeberg.org/ranmaru22/firefox-vertical-tabs.git \
  > "$ROOT/lock.json"
