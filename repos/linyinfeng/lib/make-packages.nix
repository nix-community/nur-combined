{ lib }:

let
  isSupportedUnderSystem = sys: p:
    if p.meta ? platforms
    then lib.elem sys p.meta.platforms
    else true;

  filter = system: t:
    if lib.isAttrs t
    then
      lib.mapAttrs (_name: v: if v.recurseForDerivations or false then filter system v else v)
        (lib.filterAttrs
          (_: p:
            (lib.isDerivation p && isSupportedUnderSystem system p) ||
            (lib.isAttrs p && p.recurseForDerivations or false))
          t)
    else
      throw "require an attribute set as argument";
in

path: { pkgs, ... }@args:

filter pkgs.stdenv.hostPlatform.system (import path args)
