{
  lib,
  ...
}:

let
  inherit (lib)
    filterAttrs
    isDerivation
    ;
in
{
  perSystem =
    { config, ... }:
    {
      packages = filterAttrs (_: isDerivation) config.legacyPackages;
    };
}
