{pkgs ? import <nixpkgs> {}, localUsage ? false, nixosVersion ? "master"} @ args:
let
  lib = pkgs.lib;
  shamilton = import ../. args;

  onlyUnbroken = attrs:
    lib.filterAttrs (n: v: !(builtins.hasAttr "broken" v.meta &&
    v.meta.broken )) attrs;

  onlyDerivations = attrs:
    lib.filterAttrs (n: v: lib.isDerivation v) attrs;
  
  drvsMeta = attrs:
    lib.mapAttrs (drvattr: drv: {
      name = if builtins.hasAttr "name" drv then drv.name else drvattr;
      attribute = "nur.repos.shamilton.${drvattr}";
      description = if builtins.hasAttr "meta" drv then
        ((if builtins.hasAttr "description" drv.meta then
        drv.meta.description
        else if builtins.hasAttr "longDescription" drv.meta then
        drv.meta.longDescription else "")
        ) else "";
      homepage = if builtins.hasAttr "meta" drv then (
        if builtins.hasAttr "homepage" drv.meta then
          drv.meta.homepage
        else "") else "";
    }) attrs;

  writePackageList = drvs: pkgs.writeTextFile {
    name = "packages-list.json";
    text = builtins.toJSON drvs;
  };
in 
writePackageList (lib.attrValues (drvsMeta (onlyUnbroken (onlyDerivations shamilton))))
