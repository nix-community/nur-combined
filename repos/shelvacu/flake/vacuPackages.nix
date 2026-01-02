{
  lib,
  vaculib,
  vacuRoot,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      vacuPackageNames = builtins.attrNames (import /${vacuRoot}/packages { inherit lib vaculib; });
      vacuPackagesAndMore = lib.genAttrs vacuPackageNames (name: pkgs.${name});
    in
    {
      packages = lib.filterAttrs (_: value: lib.isDerivation value) vacuPackagesAndMore;
      legacyPackages = vacuPackagesAndMore;
    };
}
