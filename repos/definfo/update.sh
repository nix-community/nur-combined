#!/usr/bin/env bash
echo "Starting package updates..."

PARALLEL_JOBS=4

update_package() {
  local package=$1
  local args=$2
  echo "=== Updating $package ==="
  nix-update --build "$package" "$args"
  echo "✓ Successfully updated $package"
  echo
}
export -f update_package

jq -r 'to_entries | .[] | .key + " " + .value' <<< '{"rime-ice":"","rime-ls":"","sjtu-canvas-helper":"","sjtu-canvas-helper-git":"--version-regex 'app-v.*'"}' | \
parallel -j $PARALLEL_JOBS update_package

echo "Update process completed!"