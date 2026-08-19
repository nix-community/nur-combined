# Cacheable derivation paths retained across all supported systems; evaluation does not build them.
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
