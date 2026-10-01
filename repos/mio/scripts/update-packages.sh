#!/usr/bin/env bash

set -euo pipefail

system="${SYSTEM:-$(nix eval --raw --impure --expr 'builtins.currentSystem')}"
package_json="$(
  nix eval --impure --json \
    --apply '
      packages:
      builtins.filter
        (name:
          let
            package = packages.${name};
          in
          builtins.isAttrs package
          && (package.type or null) == "derivation"
          && builtins.isAttrs (package.passthru or {})
          && package.passthru ? updateScript)
        (builtins.attrNames packages)
    ' ".#packages.${system}"
)" || {
  echo "Unable to discover package update scripts." >&2
  exit 1
}
mapfile -t packages < <(jq -r '.[]' <<<"$package_json")

if (( ${#packages[@]} == 0 )); then
  echo "No executable package update scripts found for ${system}." >&2
  exit 0
fi

failed=()
for package in "${packages[@]}"; do
  echo "::group::Updating ${package}"
  if nix run --impure ".#${package}.passthru.updateScript"; then
    echo "Updated ${package}."
  else
    echo "Update failed for ${package}." >&2
    failed+=("${package}")
  fi
  echo "::endgroup::"
done

if (( ${#failed[@]} > 0 )); then
  printf 'Package update failures: %s\n' "${failed[*]}" >&2
  exit 1
fi
