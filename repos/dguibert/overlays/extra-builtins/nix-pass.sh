#!/usr/bin/env bash

set -euo pipefail

f=$(mktemp)
trap "rm $f" EXIT
pass show "$1" > $f
nix-instantiate --eval --strict -E "{ success=true; value=builtins.readFile $f; }"
