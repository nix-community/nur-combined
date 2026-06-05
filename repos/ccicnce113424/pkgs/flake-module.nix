{ self, inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];
  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      packageSet = import ./. { inherit pkgs; };
    in
    {
      packages = lib.filterAttrsRecursive (
        n: p:
        !(
          builtins.any (x: x == n) [
            "callPackage"
            "newScope"
            "overrideScope"
            "packages"
            "nixosModules"
          ]
          || p.meta.broken or false
        )
      ) packageSet;
      overlayAttrs = config.packages;
    };

  flake = {
    nixosModules.default = {
      nixpkgs.overlays = [ self.overlays.default ];
    };
  };
}
