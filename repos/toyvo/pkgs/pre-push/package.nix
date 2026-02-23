{ writeShellScriptBin, lib }:
writeShellScriptBin "pre-push" ''
  echo "Check evaluation"
  nix flake show
  echo "Build nix packages"
  nix run nixpkgs#nix-fast-build -- --skip-cached --flake ".#checks.$(nix eval --raw --impure --expr builtins.currentSystem)" -j 1 --eval-workers 1
  echo "Check evaluation"
  NIX_PAGER=cat nix-env -f . -qa \* --meta --xml \
    --allowed-uris https://static.rust-lang.org \
    --option allow-import-from-derivation true \
    --drv-path --show-trace \
    -I $PWD
  echo "Build nix packages"
  nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached maintainers/ci.nix -A cacheOutputs
''
// {
  meta = {
    description = "Pre-push hook that evaluates and builds all nix packages";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "pre-push";
  };
}
