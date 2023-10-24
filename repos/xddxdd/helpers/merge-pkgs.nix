{
  stdenv,
  lib,
  enableWrapper ? true,
  ...
}: packages:
# Utility to build all derivations in `packages`.
# Passthru everything in `packages` even if not a derivation.
let
  packages' = lib.filterAttrs (k: v: lib.isDerivation v) packages;
in
  (
    if enableWrapper
    then
      (stdenv.mkDerivation {
        name = "merged-packages";
        phases = ["installPhase"];
        installPhase =
          ''
            mkdir -p $out
          ''
          + lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "ln -s ${v} $out/${k}") packages');
        passthru = packages;
      })
    else packages
  )
  // {
    recurseForDerivations = true;
  }
