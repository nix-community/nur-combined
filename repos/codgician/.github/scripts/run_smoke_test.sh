#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

package=${1:?package is required}
output=${2:?output path is required}
main_program=${3:-none}

test_drvs_json=$(nix eval --json ".#$package" --apply '
  p:
  let
    collect =
      value:
      if builtins.isAttrs value && (value.type or null) == "derivation" then
        [ value.drvPath ]
      else if builtins.isAttrs value then
        builtins.concatLists (builtins.map collect (builtins.attrValues value))
      else
        throw "passthru.tests must contain only derivations or nested test attribute sets";
  in
  if p ? tests then collect p.tests else [ ]
')
test_count=$(jq -er '
  if type == "array" and all(.[]; type == "string" and endswith(".drv"))
  then length
  else error("package test evaluation did not return derivation paths")
  end
' <<< "$test_drvs_json")

if (( test_count > 0 )); then
  mapfile -t test_drvs < <(jq -r '.[]' <<< "$test_drvs_json")
  nix build --no-link "${test_drvs[@]}"
  exit 0
fi

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
