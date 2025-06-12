#!/usr/bin/env nix-shell
#!nix-shell -i bash -p pnpm_10

update_splayer_deps_hash() {
  hash_splayer="$(nix-build --impure --expr '(import ./pkgs {}).splayer.pnpmDeps.overrideAttrs (_: { outputHash = ""; outputHashAlgo = "sha256"; })' 2>&1 | tr -s ' ' | grep -Po "got: \K.+$")" || true
  echo "SPlayer deps hash is: $hash_splayer"
  echo "\"$hash_splayer\"" >./pkgs/splayer/hash.nix
}

update_splayer_git_deps_hash() {
  hash_splayer_git="$(nix-build --impure --expr '(import ./pkgs {}).splayer-git.pnpmDeps.overrideAttrs (_: { outputHash = ""; outputHashAlgo = "sha256"; })' 2>&1 | tr -s ' ' | grep -Po "got: \K.+$")" || true
  echo "SPlayer git deps hash is: $hash_splayer_git"
  echo "\"$hash_splayer_git\"" >./pkgs/splayer/hash-git.nix
}

update_splayer_deps_hash
update_splayer_git_deps_hash
