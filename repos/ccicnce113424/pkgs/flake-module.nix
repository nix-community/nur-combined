{ self, inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];
  perSystem =
    { pkgs, ... }:
    {
      packages = import ./. { inherit pkgs; };
    };

  flake = {
    nixosModules.default = {
      nixpkgs.overlays = [ self.overlays.default ];
    };
  };
}
