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

  isDrv = n: p: !(lib.hasPrefix "_" n) && isDerivation p;
  isBuildable =
    n: p:
    (isDerivation p)
    && !(p.meta.broken or false)
    && !(p.meta.insecure or false)
    && !(p.passthru._notCI or false)
    && (isTargetPlatform p);
  isExport =
    n: p:
    !(p.passthru._usesInputs or false)
    && !(lib.hasPrefix "self-" n)
    && !(lib.hasPrefix "_" n)
    && (isDerivation p);
}
