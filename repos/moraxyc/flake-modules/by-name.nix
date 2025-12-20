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
      ...
    }@args:
    {
      ciPackages = import ../pkgs "ci" args;
      nurPackages = import ../pkgs "nur" args;
      legacyPackages = import ../pkgs "legacy" args;
    };
}
