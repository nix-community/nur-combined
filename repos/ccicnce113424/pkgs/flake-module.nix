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
      packages = lib.removeAttrs packageSet [
        "callPackage"
        "newScope"
        "overrideScope"
        "packages"
        "nixosModules"
      ];
      overlayAttrs = lib.filterAttrs (_: p: !(p.meta.broken or false)) config.packages;
    };

  flake = {
    nixosModules.default = {
      nixpkgs.overlays = [ self.overlays.default ];
    };
  };
}
