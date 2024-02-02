{
  stdenv,
  lib,
  enableWrapper,
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

        meta = let
          packagePlatforms = builtins.filter (v: v != []) (lib.mapAttrsToList (k: v: v.meta.platforms or []) packages);
          allPlatforms =
            if builtins.length packagePlatforms > 0
            then builtins.foldl' lib.intersectLists (builtins.head packagePlatforms) packagePlatforms
            else [];
        in
          {
            license =
              if builtins.all (v: v) (lib.mapAttrsToList (k: v: v.meta.license.free or false) packages)
              then lib.licenses.free
              else lib.licenses.unfree;
            broken = builtins.any (v: v) (lib.mapAttrsToList (k: v: v.meta.broken or false) packages);
          }
          // (
            if allPlatforms != []
            then {
              platforms = allPlatforms;
            }
            else {}
          );
      })
    else packages
  )
  // {
    recurseForDerivations = true;
  }
