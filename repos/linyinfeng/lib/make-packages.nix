{ lib }:

let
  isSupportedUnderSystem = sys: p:
    if p.meta ? platforms
    then lib.elem sys p.meta.platforms
    else true;

  filter = system: t:
    if lib.isAttrs t
    then
    # builtins.trace "look into"
      lib.mapAttrs (_name: v: if v.recurseForDerivations or false then filter system v else v)
        (lib.filterAttrs
          (_: p:
            !(lib.isDerivation p) ||
            # or p is a derivation
            isSupportedUnderSystem system p)
          t)
    else
      t;
in

pkgs:

filter pkgs.stdenv.hostPlatform.system
  (import ../pkgs { inherit pkgs; })
