#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

package=${1:?package is required}

if [[ ! "$package" =~ ^[a-z][a-z0-9_-]{0,63}$ ]]; then
  echo "Invalid package attribute: $package" >&2
  exit 2
fi

pname=$(nix eval --raw ".#$package.pname")
version=$(nix eval --raw ".#$package.version")
description=$(nix eval --raw ".#$package.meta.description")
homepage=$(nix eval --raw ".#$package.meta.homepage")
[[ -n "$pname" && -n "$version" && -n "$description" && -n "$homepage" ]]

nix eval --json ".#$package.meta.license" | jq -e '. != null' >/dev/null

platforms=$(nix eval --json ".#$package.meta.platforms")
jq -e 'type == "array" and length > 0 and index("x86_64-linux") != null' <<< "$platforms" >/dev/null

nix eval --json ".#$package.meta.maintainers" \
  | jq -e 'type == "array" and any(.[]; .github == "codgician" and .githubId == 15964984)' >/dev/null

nix eval --json ".#$package.meta.sourceProvenance" \
  | jq -e '
      . as $items
      | (type == "array" and length > 0)
        and ($items | all(.[];
          . as $item
          | (["fromSource", "binaryNativeCode", "binaryBytecode", "binaryFirmware", "obfuscatedCode"] | index($item.shortName) != null)
            and ($item.isSource | type == "boolean")
        ))
    ' >/dev/null

main_program_json=$(nix eval --json ".#$package" --apply 'p: p.meta.mainProgram or null')
if [[ "$main_program_json" != "null" ]]; then
  main_program=$(jq -er 'select(type == "string" and length > 0)' <<< "$main_program_json")
  if [[ ! "$main_program" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]{0,63}$ || "$main_program" == *..* ]]; then
    echo "Invalid meta.mainProgram: $main_program" >&2
    exit 2
  fi
else
  main_program=none
fi

nix eval --json .#lib.packagesWithUpdateScript \
  --apply 'packages: builtins.attrNames packages' \
  | jq -e --arg package "$package" 'index($package) != null' >/dev/null

output=$(nix build --no-link --print-out-paths ".#$package")
if [[ "$output" == *$'\n'* ]]; then
  echo "Expected one primary output path for $package" >&2
  exit 1
fi
.github/scripts/run_smoke_test.sh "$package" "$output" "$main_program"
