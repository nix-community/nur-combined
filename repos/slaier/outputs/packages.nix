{ super, modules, lib, ... }:
with super.lib;
with lib;
let
  packages = collectBlock "package" modules;
  PackageSets = collectBlock "packages" modules;
in
recursiveUpdate
  (eachDefaultSystems
    (pkgs: mapAttrs
      (name: package: pkgs.callPackage package { })
      packages))
  (eachDefaultSystems
    (pkgs: mergeAttrList (
      (mapAttrsToList (n: f: flattenPackageSet [ n ] (pkgs.callPackage f { }))) PackageSets)))
