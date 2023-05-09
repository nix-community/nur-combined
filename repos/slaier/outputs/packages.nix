{ super, modules, lib, ... }:
with super.lib;
let
  inherit (lib) recursiveUpdate last;
in
recursiveUpdate
  (eachDefaultSystems
    (pkgs: collectYield (v: v ? package)
      (path: v: { ${last path} = (pkgs.callPackage v.package { }); })
      modules))
  (eachDefaultSystems
    (pkgs: collectYield (v: v ? packages)
      (path: v: flattenPackageSet (last path) (pkgs.callPackage v.packages { }))
      modules))
