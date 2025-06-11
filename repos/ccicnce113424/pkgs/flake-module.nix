{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = import ./. { inherit pkgs; };
    };

  flake = {
    overlays.default = (_: pkgs: import ./. { inherit pkgs; });
    nixosModules.default =
      { ... }:
      {
        nixpkgs.overlays = [ self.overlays.default ];
      };
  };
}
