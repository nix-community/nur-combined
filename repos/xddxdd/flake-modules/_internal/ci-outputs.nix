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
in
{
  imports = [ ciPackagesOptionModule ];

  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs.callPackage ../../helpers/is-buildable.nix { }) isBuildable;
      nvfetcherLoader = pkgs.callPackage ../../helpers/nvfetcher-loader.nix { };
      sources = nvfetcherLoader ../../_sources/generated.nix;
    in
    rec {
      ciPackages = lib.filterAttrs (_n: isBuildable) (
        (import ../../pkgs "ci" { inherit inputs pkgs; })
        // (lib.mapAttrs' (n: v: lib.nameValuePair "nvfetcher-src-${n}" v.src or null) sources)
      );
    };
}
