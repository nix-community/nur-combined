{ super, modules, lib, ... }:
with super.lib;
let
  inherit (lib) last;
in
eachDefaultSystems (pkgs:
(collectYield (v: v ? package)
  (path: v: { ${last path} = (pkgs.callPackage v.package { }); })
  modules) //
(collectYield (v: v ? packages)
  (path: v: flattenPackageSet (last path) (pkgs.callPackage v.packages { }))
  modules) //
super.installer
)
