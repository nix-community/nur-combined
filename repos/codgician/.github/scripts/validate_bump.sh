#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

package=${1:?package is required}
baseline_main_program=${2:?baseline main program is required}
if [[ ! "$package" =~ ^[a-z][a-z0-9_-]{0,63}$ ]]; then
  echo "Invalid package attribute: $package" >&2
  exit 2
fi
if [[ "$baseline_main_program" != "none" && ( ! "$baseline_main_program" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]{0,63}$ || "$baseline_main_program" == *..* ) ]]; then
  echo "Invalid baseline main program: $baseline_main_program" >&2
  exit 2
fi

output=$(nix build --no-link --print-out-paths ".#$package")
if [[ "$output" == *$'\n'* ]]; then
  echo "Expected one primary output path for $package" >&2
  exit 1
fi

if ! main_program=$(nix eval --raw ".#$package.meta.mainProgram" 2>/dev/null); then
  if [[ "$baseline_main_program" != "none" ]]; then
    echo "Package removed its required meta.mainProgram: $baseline_main_program" >&2
    exit 1
  fi
  exit 0
fi
if [[ ! "$main_program" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]{0,63}$ || "$main_program" == *..* ]]; then
  echo "Invalid meta.mainProgram: $main_program" >&2
  exit 1
fi
if [[ "$baseline_main_program" != "none" && "$main_program" != "$baseline_main_program" ]]; then
  echo "Package changed meta.mainProgram from $baseline_main_program to $main_program" >&2
  exit 1
fi

program="$output/bin/$main_program"
resolved=$(readlink -f "$program")
if [[ ! -x "$program" || "$resolved" != "$output/"* ]]; then
  echo "meta.mainProgram is not a contained executable: $program" >&2
  exit 1
fi
timeout 30 "$program" --help >/dev/null
