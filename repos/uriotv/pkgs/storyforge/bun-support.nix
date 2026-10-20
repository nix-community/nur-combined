# Adapt only bun2nix's dependency/cache modules, not its flake or package set.
{ pkgs }:
let
  inherit (pkgs) lib;
  pin = builtins.fromJSON (builtins.readFile ./bun2nix-pin.json);
  source = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "bun2nix";
    inherit (pin) rev hash;
  };
  # These pinned modules separate their option declarations from their values.
  # We use the values directly; no flake-parts evaluation or IFD is needed.
  load =
    path:
    let
      module = import (./bun-support + "/${path}.nix") {
        inherit lib;
        flake-parts-lib.mkPerSystemOption = value: value;
        config = {
          cargoTOML.package.version = pin.version;
          bun2nixSource = source;
        };
      };
    in
    (module.perSystem or module.config.perSystem) {
      inherit pkgs config;
      self'.packages = config.packages;
    };
  config = lib.foldl' lib.recursiveUpdate { } (
    map load [
      "fetch-bun-deps"
      "fetch-bun-deps/build-package"
      "fetch-bun-deps/override-package"
      "fetch-bun-deps/extract-package"
      "fetch-bun-deps/bun-with-node"
      "fetch-bun-deps/cache-entry-creator"
      "mk-derivation/hook"
      "mk-derivation/bun2nix-no-op"
    ]
  );
in
{
  inherit (config.mkDerivation) hook;
  fetchBunDeps = config.fetchBunDeps.function;
}
