{
  self,
  lib,
  flake-parts-lib,
  inputs,
  ...
}:
let
  ciPackagesOptionModule = flake-parts-lib.mkTransposedPerSystemModule {
    name = "ciPackages";
    option = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.package;
      default = [ ];
    };
    file = ./ci-outputs.nix;
  };
  ciOutputsOptionModule = flake-parts-lib.mkTransposedPerSystemModule {
    name = "ciOutputs";
    option = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
    file = ./ci-outputs.nix;
  };
in
{
  imports = [
    ciPackagesOptionModule
    ciOutputsOptionModule
  ];

  perSystem =
    { pkgs, system, ... }:
    let
      inherit (pkgs.callPackage ../../helpers/is-buildable.nix { }) isBuildable isSourceFetchable;
      outputsOf = p: map (o: p.${o}) p.outputs;
      nvfetcherLoader = pkgs.callPackage ../../helpers/nvfetcher-loader.nix { };
      sources = nvfetcherLoader ../../_sources/generated.nix;
    in
    rec {
      ciPackages = lib.filterAttrs (_n: isBuildable) (import ../../pkgs "ci" { inherit inputs pkgs; });
      ciOutputs =
        (lib.flatten (lib.mapAttrsToList (_: outputsOf) ciPackages))
        ++ (builtins.filter (p: lib.isDerivation p && (builtins.tryEval p).success) (
          lib.flatten (
            lib.mapAttrsToList (_: v: v.srcs or v.src or null) (
              lib.filterAttrs (_n: isSourceFetchable) self.packages.${system}
            )
          )
        ))
        ++ (builtins.filter (v: v != null) (lib.mapAttrsToList (_: v: v.src or null) sources));
    };
}
