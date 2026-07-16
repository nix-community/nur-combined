#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

old_version=${1:?old version is required}
new_version=${2:?new version is required}
version_pattern='^[0-9A-Za-z][0-9A-Za-z._+~-]{0,127}$'

if [[ ! "$old_version" =~ $version_pattern ]]; then
  echo "Invalid old package version: $old_version" >&2
  exit 2
fi
if [[ ! "$new_version" =~ $version_pattern ]]; then
  echo "Invalid new package version: $new_version" >&2
  exit 2
fi

if [[ "$old_version" =~ ^0-unstable-[0-9]{4}-[0-9]{2}-[0-9]{2}$ && ! "$new_version" =~ ^0-unstable-[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Package changed its date-only unstable version format: $old_version -> $new_version" >&2
  exit 1
fi
if [[ "$old_version" =~ ^unstable-[0-9]{4}-[0-9]{2}-[0-9]{2}$ && ! "$new_version" =~ ^unstable-[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Package changed its date-only unstable version format: $old_version -> $new_version" >&2
  exit 1
fi

comparison=$(nix eval --raw --expr "builtins.toString (builtins.compareVersions \"$old_version\" \"$new_version\")")
case "$comparison" in
  -1) printf 'advanced' ;;
  0) printf 'unchanged' ;;
  1) printf 'regressed' ;;
  *)
    echo "Unexpected version comparison result: $comparison" >&2
    exit 1
    ;;
esac
