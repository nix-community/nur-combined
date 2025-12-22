{
  lib,
  vaculib,
  vacuRoot,
  ...
}:
let
  vacuPackageNames = builtins.attrNames (import /${vacuRoot}/packages { inherit lib vaculib; });
in
{
  perSystem = { pkgs, ... }: {
    packages = lib.genAttrs vacuPackageNames (name: pkgs.${name});
  };
}
