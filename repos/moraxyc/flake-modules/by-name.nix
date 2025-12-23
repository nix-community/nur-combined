{
  lib,
  flake-parts-lib,
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
      inputs',
      ...
    }@args:
    rec {
      packages = legacyPackages.__drvPackages;
      ciPackages = legacyPackages.__ciPackages;
      nurPackages = legacyPackages.__nurPackages;
      legacyPackages = import ../pkgs args;
    };
}
