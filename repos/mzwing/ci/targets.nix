# Package outputs that CI builds and caches, listed for every supported
# system. Evaluated by the "Evaluate supported packages" step of
# .github/workflows/build.yml:
#
#   nix eval --json --impure --file ci/targets.nix
#
# --impure is required because ci/default.nix reads NUR_COMPILE_CACHE from
# the environment (which changes output paths when enabled).
let
  flake = builtins.getFlake "path:${toString ../.}";
  systems = import ../internal/systems.nix;
in
  builtins.concatMap (
    system: let
      pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
      craneLib = flake.inputs.crane.mkLib pkgs;
    in
      (import ./. {inherit pkgs craneLib;}).cacheTargets
  )
  systems
