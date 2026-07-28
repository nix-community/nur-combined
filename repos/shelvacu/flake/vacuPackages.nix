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
  vacuBuilds = lib.genAttrs vacuPackageNames (_: {
    putInPackages = true;
  });
  perSystem = { pkgs, ... }: {
    vacuBuildDerivations = lib.genAttrs vacuPackageNames (name: pkgs.${name});
    legacyPackages = builtins.mapAttrs (name: _: pkgs.${name}) (
      import /${vacuRoot}/legacyPackages { inherit lib vaculib; }
    );
  };
}
