{
  lib,
  enableWrapper,
  runCommand,
  ...
}:
packages:
# Utility to build all derivations in `packages`.
# Passthru everything in `packages` even if not a derivation.
let
  packages' = lib.filterAttrs (_k: v: lib.isDerivation v) packages;
in
if packages == null then
  null
else
  (
    if enableWrapper then
      runCommand "merged-packages"
        {
          passthru = packages;

          srcs = lib.flatten (
            builtins.filter (v: v != null) (lib.mapAttrsToList (_: v: v.srcs or v.src or null) packages)
          );

          meta =
            let
              allMetas = lib.mapAttrsToList (
                _k: v:
                let
                  evalResult = builtins.tryEval v;
                in
                if evalResult.success then evalResult.value.meta or { } else { }
              ) packages;

              packagePlatforms = builtins.filter (v: v != [ ]) (builtins.map (v: v.platforms or [ ]) allMetas);
              allPlatforms =
                if builtins.length packagePlatforms > 0 then
                  builtins.foldl' lib.intersectLists (builtins.head packagePlatforms) packagePlatforms
                else
                  [ ];
            in
            {
              license =
                if builtins.all (v: v) (builtins.map (v: v.license.free or false) allMetas) then
                  lib.licenses.free
                else
                  lib.licenses.unfree;
              broken = builtins.any (v: v) (builtins.map (v: v.broken or false) allMetas);
            }
            // (if allPlatforms != [ ] then { platforms = allPlatforms; } else { });
        }
        (
          ''
            mkdir -p $out
          ''
          + lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "ln -s ${v} $out/${k}") packages')
        )
    else
      packages
  )
  // {
    recurseForDerivations = true;
  }
