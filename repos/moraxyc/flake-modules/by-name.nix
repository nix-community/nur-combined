{
  lib,
  flake-parts-lib,
  inputs,
  ...
}:
{
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "nurPackages";
      option = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = [ ];
      };
      file = ./by-name.nix;
    })
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "ciPackages";
      option = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = [ ];
      };
      file = ./by-name.nix;
    })
  ];
  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    rec {
      packages = legacyPackages.__drvPackages;
      ciPackages = legacyPackages.__ciPackages;
      nurPackages = legacyPackages.__nurPackages;
      legacyPackages = import ../pkgs {
        inherit
          pkgs
          config
          lib
          inputs
          ;
      };
    };
}
