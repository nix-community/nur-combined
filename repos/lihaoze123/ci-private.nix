{ lib, packages, system }:

let
  buildJobPackages = lib.filterAttrs
    (_: package:
      lib.isDerivation package
      && !(package.meta.broken or false)
      && lib.meta.availableOn (lib.systems.elaborate system) package)
    packages;
in
{
  inherit buildJobPackages;
  updateScripts = lib.mapAttrs (_: package: package.updateScript)
    (lib.filterAttrs (_: package: package ? updateInfo) packages);
  outputPaths = lib.concatMap
    (package: map (output: package.${output}.outPath) package.outputs)
    (lib.attrValues buildJobPackages);
}
