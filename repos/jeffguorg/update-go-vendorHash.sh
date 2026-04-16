#!/usr/bin/env bash

set -euo pipefail

run_timestamp=$(date +%s)
sed_replacements=()
need_rebuild=()

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

for DERIVATION_NAME in "${derivations[@]}"; do
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
      sed_replacements=("${sed_replacements[@]}" -e "s,$specified,$got,")
      need_rebuild=("${need_rebuild[@]}" "${DERIVATION_NAME}")
    fi
  fi
done

if [ "${#sed_replacements[@]}" -eq 0 ]; then
  echo "nothing to be replaced"
  exit
fi

while IFS= read -r -d '' ENTRY; do
  sed -i "${sed_replacements[@]}" $ENTRY
done < <(find -type f -name '*.nix' -print0)

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
