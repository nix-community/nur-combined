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
          && (package.passthru ? updateScript)
        )
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
  
  is_drv=$(nix eval --impure --json ".#packages.${system}.${package}.passthru.updateScript.type" 2>/dev/null || echo '""')
  if [[ "$is_drv" == '"derivation"' ]]; then
    if nix run --impure ".#${package}.passthru.updateScript"; then
      echo "Updated ${package}."
    else
      echo "Update failed for ${package}." >&2
      failed+=("${package}")
    fi
  else
    echo "Running non-derivation update script for ${package}..."
    script_json=$(nix eval --impure --json ".#packages.${system}.${package}.passthru.updateScript" 2>/dev/null || echo "")
    if [[ -n "$script_json" && "$script_json" != '""' ]]; then
      if echo "$script_json" | jq -e 'type == "array"' > /dev/null; then
        mapfile -t cmd_args < <(echo "$script_json" | jq -r '.[]')
        if env UPDATE_NIX_ATTR_PATH="${package}" "${cmd_args[@]}"; then
          echo "Updated ${package}."
        else
          echo "Update failed for ${package}." >&2
          failed+=("${package}")
        fi
      elif echo "$script_json" | jq -e 'type == "string"' > /dev/null; then
        script_path=$(echo "$script_json" | jq -r '.')
        if env UPDATE_NIX_ATTR_PATH="${package}" "$script_path"; then
          echo "Updated ${package}."
        else
          echo "Update failed for ${package}." >&2
          failed+=("${package}")
        fi
      else
        echo "Unsupported updateScript format for ${package}." >&2
        failed+=("${package}")
      fi
    else
      echo "Failed to evaluate updateScript for ${package}." >&2
      failed+=("${package}")
    fi
  fi
  echo "::endgroup::"
done

if (( ${#failed[@]} > 0 )); then
  printf 'Package update failures: %s\n' "${failed[*]}" >&2
  exit 1
fi
