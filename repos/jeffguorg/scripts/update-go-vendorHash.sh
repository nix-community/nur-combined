#!/usr/bin/env bash

set -euo pipefail

run_timestamp=$(date +%s)
sed_replacements=()
replace_files=()
need_rebuild=()
target_list="${1:-${GO_VENDORHASH_TARGETS:-}}"

contains_target() {
  local target="$1"

  [[ -z "$target_list" || "$target_list" == *":${target}:"* ]]
}

derivations=(
  $(nix eval --impure --json --expr '
let
  pkgs = (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [
        (import "${fetchTree gomod2nix.locked}/overlay.nix")
      ];
    }
  );
  attrs = pkgs.callPackage ./default.nix {};
  lib = pkgs.lib;
in
  builtins.attrNames
    (lib.filterAttrs (_: v:
      lib.isDerivation v && v ? goModules
    ) attrs)
    ' | jq -r '.[]')
)

selected_derivations=()
for DERIVATION_NAME in "${derivations[@]}"; do
  if contains_target "$DERIVATION_NAME"; then
    selected_derivations+=("${DERIVATION_NAME}")
  fi
done

if [ "${#selected_derivations[@]}" -eq 0 ]; then
  echo "no go vendor hash targets selected"
  exit 0
fi

for DERIVATION_NAME in "${selected_derivations[@]}"; do
  if ! output="$(nix-build -E "
 let
  pkgs = (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [
        (import \"\${fetchTree gomod2nix.locked}/overlay.nix\")
      ];
      config.allowUnfree = true;
    }
  );
  attrs = pkgs.callPackage ./default.nix {};
in attrs.$DERIVATION_NAME
" 2>&1 | tee /dev/stderr)"; then
    specified=$(echo "$output" | awk -F: '$1~/specified/{print $2}' | xargs)
    got=$(echo "$output" | awk -F: '$1~/got/{print $2}' | xargs)
    if [ -n "$specified" -a -n "$got" ]; then
      echo "hash replacement detected. searching for hashes: $specified -> $got"
      while IFS= read -r ENTRY; do
        [ -n "$ENTRY" ] && replace_files+=("$ENTRY")
      done < <(rg -l -F "$specified" --glob '*.nix' .)
      sed_replacements=("${sed_replacements[@]}" "$specified" "$got")
      need_rebuild=("${need_rebuild[@]}" "${DERIVATION_NAME}")
    fi
  fi
done

if [ "${#sed_replacements[@]}" -eq 0 ]; then
  echo "nothing to be replaced"
  exit
fi

if [ "${#replace_files[@]}" -eq 0 ]; then
  echo "no nix files matched the old vendor hashes"
  exit 1
fi

mapfile -t replace_files < <(printf '%s\n' "${replace_files[@]}" | sort -u)

for ENTRY in "${replace_files[@]}"; do
  for ((i = 0; i < ${#sed_replacements[@]}; i += 2)); do
    sed -i "s,${sed_replacements[i]},${sed_replacements[i + 1]},g" "$ENTRY"
  done
done

for DERIVATION_NAME in "${need_rebuild[@]}"; do
  nix-build -E "
   let
    pkgs = (
      let
        inherit (builtins) fetchTree fromJSON readFile;
        inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs gomod2nix;
      in
      import (fetchTree nixpkgs.locked) {
        overlays = [
          (import \"\${fetchTree gomod2nix.locked}/overlay.nix\")
        ];
        config.allowUnfree = true;
      }
    );
    attrs = pkgs.callPackage ./default.nix {};
  in attrs.$DERIVATION_NAME
  "
done
