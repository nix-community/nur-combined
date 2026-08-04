{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      legacyPackages = import ./.. {
        inherit pkgs;
      };

      packages = lib.filterAttrs (_: v: lib.isDerivation v) self'.legacyPackages;
    };
}
