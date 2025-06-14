{ self, inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];
  perSystem =
    { pkgs, config, ... }:
    {
      packages = import ./. { inherit pkgs; };
      overlayAttrs = config.packages;
    };

  flake = {
    nixosModules.default = {
      nixpkgs.overlays = [ self.overlays.default ];
    };
  };
}
