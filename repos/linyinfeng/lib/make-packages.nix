{ lib }:

let
  isSupportedUnderSystem = sys: p:
    if p.meta ? platforms
    then lib.elem sys p.meta.platforms
    else true;
in

pkgs:

lib.filterAttrs
  (_: p:
    !(lib.isDerivation p) ||
    # or p is a derivation
    isSupportedUnderSystem pkgs.system p)
  (import ../pkgs { inherit pkgs; })
