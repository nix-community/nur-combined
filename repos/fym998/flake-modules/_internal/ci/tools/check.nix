{ nix-fast-build, writeShellScriptBin }:
writeShellScriptBin "check" ''
  ${nix-fast-build}/bin/nix-fast-build \
    --skip-cached --no-nom \
    --flake ".#checks.$(nix eval --raw --impure --expr builtins.currentSystem)"
''
