{
  system,
  pkgs,
  nixpkgs,
}:
let
  # from https://github.com/NixOS/nixpkgs/blob/master/lib/systems/examples.nix
  targets = [
    {
      system = pkgs.lib.systems.examples.x86_64-darwin;
      normalized = "x86_64-darwin";
    }
    {
      system = pkgs.lib.systems.examples.aarch64-darwin;
      normalized = "aarch64-darwin";
    }
    {
      system = pkgs.lib.systems.examples.gnu64;
      normalized = "x86_64-linux";
    }
    {
      system = pkgs.lib.systems.examples.aarch64-multiplatform;
      normalized = "aarch64-linux";
    }
  ];
in
builtins.listToAttrs (
  builtins.map (
    target:
    pkgs.lib.attrsets.nameValuePair "docker-${target.normalized}" (
      drv:
      let
        drvOverlay = final: prev: {
          "${drv.pname}" = drv;
        };

        crossPkgs = import nixpkgs {
          localSystem = system;
          crossSystem = target.system;
          overlays = [
            drvOverlay
          ];
        };

      in
      crossPkgs.callPackage ./default.nix {
        name = "${drv.pname}";
        pkgs = crossPkgs;
      }
    )
  ) targets
)
