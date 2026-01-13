#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -eq 0 ]]; then
  echo "usage: $0 [option...] <url>" >&2
  echo "options: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-hash-file.html#options" >&2
  exit 1
fi

tmpdir=$(mktemp -d)
wget -q -P "${tmpdir}" "${@: -1}"
file=$(find "${tmpdir}" -type f -print -quit)
nix hash file "${@:1:$#-1}" "${file}" 2> /dev/null
rm -r "${tmpdir}"
