{
  self,
  inputs,
  lib,
  ...
}:

let
  # rename `self.legacyPackages.*.packages` -> `self.legacyPackages.*.packages'`
  # `self.legacyPackages.*.packages` collides with `self.packages` in nix cli
  adjustLegacyPackages =
    pkgs: lib.attrsets.removeAttrs pkgs [ "packages" ] // { packages' = pkgs.packages; };
in
{
  perSystem =
    { self', pkgs, ... }:
    {
      nixpkgs.config = {
        allowUnfree = true;
      };
      legacyPackages = adjustLegacyPackages (self.lib.makePackages pkgs ../pkgs { selfLib = self.lib; });
      packages = inputs.flake-utils.lib.flattenTree (self'.legacyPackages);
    };
}
