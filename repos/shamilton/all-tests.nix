{pkgs ? import <nixpkgs> {}, localUsage ? false, nixosVersion ? "master"} @ args:
let
  lib = pkgs.lib;
  shamilton = import ./. args;
  onlyUnbroken = attrs:
    lib.filterAttrs (n: v: !(builtins.hasAttr "broken" v.meta && v.meta.broken )) attrs;
  onlyDerivations = attrs:
    lib.filterAttrs (n: v: lib.isDerivation v) attrs;
in 
lib.attrValues (onlyUnbroken (onlyDerivations shamilton.tests))
