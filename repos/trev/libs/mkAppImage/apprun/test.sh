#!/usr/bin/env bash

# shellcheck disable=SC2128
LOCATION="$(dirname -- "$(readlink -f "${BASH_SOURCE}")")"
# shellcheck disable=SC2046
# shellcheck disable=SC2010
# shellcheck disable=SC2068
"$LOCATION"/bwrap $(ls / | grep -v -E "dev|proc" | xargs -I % echo --bind /% /% | tr '\n' ' ') --dev-bind /dev /dev --proc /proc --ro-bind "$LOCATION"/nix /nix $(readlink "$LOCATION"/entrypoint) $@
