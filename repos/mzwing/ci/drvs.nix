# Derivation files (.drv) for every package output CI builds and caches,
# listed for every supported system. Evaluated by the GC step of the
# "cache" job in .github/workflows/build.yml:
#
#   nix eval --json --impure --file ci/drvs.nix
#
# The cache machine uses the build-time closure of these derivations
# (nix-store --query --requisites --include-outputs) as the GC keep-set:
# store paths outside that closure are collected before the store is
# saved to the GitHub Actions cache.
#
# Only instantiates derivations; nothing is built, so evaluating foreign
# systems is fine.
let
  flake = builtins.getFlake "path:${toString ../.}";
  systems = import ../internal/systems.nix;
in
  builtins.concatMap (
    system: let
      pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
    in
      map (package: package.drvPath) (import ./. {inherit pkgs;}).cachePkgs
  )
  systems
