{ writeShellScriptBin, lib, ... }:
writeShellScriptBin "pre-push" ''
  echo "Check evaluation"
  nix flake show
  echo "Build nix packages"
  nix build --print-build-logs ".#checks.$(nix eval --raw --impure --expr builtins.currentSystem).all"
  echo "Check evaluation"
  NIX_PAGER=cat nix-env -f . -qa \* --meta --xml \
    --allowed-uris https://static.rust-lang.org \
    --option allow-import-from-derivation true \
    --drv-path --show-trace \
    -I $PWD
  echo "Build nix packages"
  nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached ci.nix -A cacheOutputs
''
// {
  meta = {
    description = "Pre-push hook that evaluates and builds all nix packages";
    homepage = "https://github.com/ToyVoDev/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "pre-push";
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ toyvo ];
  };
}
