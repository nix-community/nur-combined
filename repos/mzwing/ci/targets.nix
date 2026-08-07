# Package outputs that CI builds and caches, listed for every supported
# system. Evaluated by the "Evaluate supported packages" step of
# .github/workflows/build.yml:
#
#   nix eval --json --impure --file ci/targets.nix
let
  flake = builtins.getFlake "path:${toString ../.}";
  systems = import ../internal/systems.nix;
in
  builtins.concatMap (
    system: let
      pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
    in
      (import ./. {inherit pkgs;}).cacheTargets
  )
  systems
