#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnugrep
build_output=$(nix build --impure --expr '(import ./pkgs {}).splayer-git.pnpmDeps.overrideAttrs (_: { outputHash = ""; outputHashAlgo = "sha256"; })' 2>&1) || true
echo "SPlayer git deps build output is: $build_output"
hash_splayer_git=$(tr -s ' ' <<<$build_output | grep -Po "got: \K.+$")
if [ -z "$hash_splayer_git" ]; then
  echo "Failed to extract hash from build output."
  exit 1
fi
echo "SPlayer git deps hash is: $hash_splayer_git"
echo "\"$hash_splayer_git\"" >pkgs/splayer-git/hash-git.nix
