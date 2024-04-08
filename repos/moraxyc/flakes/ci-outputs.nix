{
  self,
  lib,
  flake-parts-lib,
  inputs,
  ...
}: let
  ciPackagesOptionModule = flake-parts-lib.mkTransposedPerSystemModule {
    name = "ciPackages";
    option = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.package;
      default = [];
    };
    file = ./ci-outputs.nix;
  };
  ciOutputsOptionModule = flake-parts-lib.mkTransposedPerSystemModule {
    name = "ciOutputs";
    option = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
    file = ./ci-outputs.nix;
  };
in {
  imports = [
    ciPackagesOptionModule
    ciOutputsOptionModule
  ];

  perSystem = {
    config,
    system,
    pkgs,
    ...
  }: let
    flattenPkgs = pkgs.callPackage ./fn/flatten-pkgs.nix {};
    inherit (flattenPkgs) isDerivation isTargetPlatform;
    isBuildable = p:
      (isDerivation p)
      && !(p.meta.broken or false)
      && !(p.preferLocalBuild or false)
      && (isTargetPlatform p);
    outputsOf = p: map (o: p.${o}) p.outputs;
  in rec {
    ciPackages = lib.filterAttrs (n: isBuildable) (import ../pkgs "ci" {inherit inputs pkgs;});
    ciOutputs = lib.flatten (lib.mapAttrsToList (_: outputsOf) ciPackages);
  };
}
