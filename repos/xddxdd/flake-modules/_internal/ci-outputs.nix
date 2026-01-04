{
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
  ciPackagesWithCudaOptionModule = flake-parts-lib.mkTransposedPerSystemModule {
    name = "ciPackagesWithCuda";
    option = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.package;
      default = [ ];
    };
    file = ./ci-outputs.nix;
  };
  packagesWithCudaOptionModule = flake-parts-lib.mkTransposedPerSystemModule {
    name = "packagesWithCuda";
    option = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.package;
      default = [ ];
    };
    file = ./ci-outputs.nix;
  };
  legacyPackagesWithCudaOptionModule = flake-parts-lib.mkTransposedPerSystemModule {
    name = "legacyPackagesWithCuda";
    option = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.anything;
      default = [ ];
    };
    file = ./ci-outputs.nix;
  };
in
{
  imports = [
    ciPackagesOptionModule
    ciPackagesWithCudaOptionModule
    packagesWithCudaOptionModule
    legacyPackagesWithCudaOptionModule
  ];

  perSystem =
    { pkgs, pkgsWithCuda, ... }:
    let
      inherit (pkgs.callPackage ../../helpers/is-buildable.nix { }) isBuildable;
      inherit (pkgs.callPackage ../../helpers/flatten-pkgs.nix { })
        flattenPkgs
        ;
      nvfetcherLoader = pkgs.callPackage ../../helpers/nvfetcher-loader.nix { };
      sources = nvfetcherLoader ../../_sources/generated.nix;
    in
    rec {
      ciPackages = lib.filterAttrs (n: isBuildable) (
        (flattenPkgs (import ../../pkgs "ci" { inherit inputs pkgs; }))
        // (lib.mapAttrs' (n: v: lib.nameValuePair "nvfetcher-src-${n}" v.src or null) sources)
      );
      ciPackagesWithCuda = lib.filterAttrs (n: isBuildable) (
        (flattenPkgs (
          import ../../pkgs "ci" {
            inherit inputs;
            pkgs = pkgsWithCuda;
          }
        ))
        // (lib.mapAttrs' (n: v: lib.nameValuePair "nvfetcher-src-${n}" v.src or null) sources)
      );
    };
}
