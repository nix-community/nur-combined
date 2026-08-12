# Derivation files (.drv) for every package output CI builds and caches,
# listed for every supported system. Evaluated by the coordinator's
# reconcile-builder-store-cache action in .github/workflows/build.yml:
#
#   nix eval --json --impure --file ci/drvs.nix
#
# Reconciliation expands their build-time closure for retention, uploads
# missing private outputs of the separately supplied scheduled derivations,
# and installs the deterministic keep-set used to prune stale Attic objects
# before GitHub Actions Cache saves them.
# Public-cache paths may remain references but are not persisted privately.
#
# The full list defines retention across inactive systems; the action receives
# the exact scheduled derivations separately as its transfer set. Only
# instantiates derivations; nothing is built, so evaluating foreign systems is
# fine.
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
