{
  lib,
  system,
  ...
}: rec {
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
  isIndependentDerivation = p: isDerivation p && p.name != "merged-packages";
  isHiddenName = n: lib.hasPrefix "_" n || n == "stdenv";
  isTargetPlatform = p: lib.elem system (p.meta.platforms or [system]);
  shouldRecurseForDerivations = p: lib.isAttrs p && p.recurseForDerivations or false;

  isBuildable = p:
    (isDerivation p)
    && !(p.meta.broken or false)
    && !(p.preferLocalBuild or false)
    && (isTargetPlatform p);
}
