{
  lib,
  stdenv,
  ...
}:
let
  system = stdenv.hostPlatform.system;
in
rec {
  isDerivation = p: lib.isAttrs p && p ? type && p.type == "derivation";
  isTargetPlatform = isTargetPlatform' system;
  isTargetPlatform' = system: p: lib.elem system (p.meta.platforms or [ system ]);

  isBuildable =
    n: p:
    (isDerivation p)
    && !(p.meta.broken or false)
    && !(p.meta.insecure or false)
    && (isTargetPlatform p);
  isExport =
    n: p: !(lib.hasPrefix "self-" n) && (n != "sources") && !(lib.hasPrefix "_" n) && (isDerivation p);
}
