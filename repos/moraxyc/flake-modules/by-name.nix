{
  lib,
  flake-parts-lib,
  inputs,
  self,
  ...
}:
{
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "nurPackages";
      option = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
      };
      file = ./by-name.nix;
    })
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "ciPackages";
      option = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
      };
      file = ./by-name.nix;
    })
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "nixosTests";
      option = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
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
      nixosTests = lib.optionalAttrs (
        pkgs.stdenv.hostPlatform.system == "x86_64-linux"
      ) legacyPackages.__nixosTests;
      nurPackages = legacyPackages.__nurPackages;
      legacyPackages = import ../pkgs/top-level {
        inherit
          pkgs
          config
          lib
          inputs
          self
          ;
      };
    };
}
