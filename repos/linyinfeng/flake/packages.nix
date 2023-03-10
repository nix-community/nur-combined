{ self, inputs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
  };

  perSystem = { self', pkgs, ... }:
    {
      legacyPackages = self.lib.makePackages pkgs ../pkgs {
        selfLib = self.lib;
      };
      packages = inputs.flake-utils.lib.flattenTree (self'.legacyPackages);
    };
}
