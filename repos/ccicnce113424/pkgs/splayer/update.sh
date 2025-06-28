#!/usr/bin/env nix-shell
#!nix-shell -i bash -p pnpm_10
hash_splayer="$(nix-build --impure --expr '(import ./pkgs {}).splayer.pnpmDeps.overrideAttrs (_: { outputHash = ""; outputHashAlgo = "sha256"; })' 2>&1 | tr -s ' ' | grep -Po "got: \K.+$")" || true
echo "SPlayer deps hash is: $hash_splayer"
echo "\"$hash_splayer\"" >pkgs/splayer/hash.nix
