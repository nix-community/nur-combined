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
    {
      config,
      system,
      pkgs,
      ...
    }:
    let
      inherit (pkgs.callPackage ../helpers/is-buildable.nix { }) isBuildable;
      outputsOf = p: map (o: p.${o}) p.outputs;
    in
    rec {
      ciPackages = lib.filterAttrs (n: isBuildable) (import ../pkgs "ci" { inherit inputs pkgs; });
      ciOutputs = lib.flatten (lib.mapAttrsToList (_: outputsOf) ciPackages);
    };
}
