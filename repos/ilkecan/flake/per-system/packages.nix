{
  lib,
  ...
}:

{
  perSystem =
    { config, ... }:
    {
      packages = lib.filterAttrs (_: lib.isDerivation) config.legacyPackages;
    };
}
