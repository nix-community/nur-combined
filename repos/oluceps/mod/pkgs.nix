{
  self,
  inputs,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem =
    {
      pkgs,
      lib,
      system,
      config,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays =
          map
            (
              i:
              if inputs.${i}.overlays ? "default" then inputs.${i}.overlays.default else inputs.${i}.overlays.${i}
            )
            [
              "fenix"
              "self"
              "nuenv"
            ];
        config = {
          allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "veracrypt"
              "tetrio-desktop"
            ];
        };
      };

      overlayAttrs = config.packages;
      packages =
        (lib.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ../pkgs/by-name;
        })
        // {
          default = pkgs.symlinkJoin {
            name = "user-pkgs";
            paths = import ../user-pkgs.nix { inherit pkgs; };
          };
        };
    };
}
