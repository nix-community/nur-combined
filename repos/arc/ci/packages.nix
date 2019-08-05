{ arc }:
with arc.pkgs.lib; let
  packages = filterAttrs filter arc.packages;
  packages' = mapAttrs (_: p: if !isDerivation p && isAttrs p
    then filterAttrs filter p
    else p
  ) packages;
  filter = _: pkg: (!isAttrs pkg || !isDerivation pkg) || (!(pkg.meta.broken or false) &&
    !(pkg.meta.skip.ci or false) &&
    pkg.meta.available or true);
in builtins.attrValues packages'
