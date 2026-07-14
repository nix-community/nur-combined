#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

package=${1:?package is required}
output=${2:?output path is required}
main_program=${3:-none}

has_smoke=$(nix eval --json ".#$package" --apply 'p: p ? tests.smoke')
case "$has_smoke" in
  true)
    exec nix build --no-link ".#$package.tests.smoke"
    ;;
  false) ;;
  *)
    echo "Could not determine whether $package provides tests.smoke" >&2
    exit 1
    ;;
esac

if [[ "$main_program" == "none" ]]; then
  exit 0
fi
if [[ ! "$main_program" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]{0,63}$ || "$main_program" == *..* ]]; then
  echo "Invalid meta.mainProgram: $main_program" >&2
  exit 2
fi

program="$output/bin/$main_program"
resolved=$(readlink -f "$program")
if [[ ! -x "$program" || "$resolved" != "$output/"* ]]; then
  echo "meta.mainProgram is not a contained executable: $program" >&2
  exit 1
fi

smoke_home=$(mktemp -d)
trap 'rm -rf "$smoke_home"' EXIT
(
  cd "$smoke_home"
  HOME="$smoke_home" XDG_DATA_HOME="$smoke_home/data" timeout 30 "$program" --help >/dev/null
)
