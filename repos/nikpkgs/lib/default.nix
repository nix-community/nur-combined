{ pkgs }:
let
  inherit (pkgs) lib;
in
{
  nvfetcherLoader =
    sourcesFile:
    let
      sources = pkgs.callPackage sourcesFile { };
      cleanVersion = v: lib.removePrefix "V" (lib.removePrefix "v" v);
    in
    lib.mapAttrs (
      n: v:
      if !(lib.isAttrs v) then
        v
      else
        let
          baseData = {
            version = cleanVersion v.version;
          };

          isUnstable =
            (builtins.hasAttr "version" v)
            && (builtins.match "[0-9a-f]{40}" v.version != null)
            && (builtins.hasAttr "date" v);

          unstableData =
            if isUnstable then
              let
                # Try find package with '-stable' suffix
                stablePkgName = "${n}-stable";
                lastStableVersion =
                  if builtins.hasAttr stablePkgName sources then
                    cleanVersion sources.${stablePkgName}.version
                  else
                    "0";
              in
              {
                # Format: 1.2.3-unstable-2025-01-01
                version = "${lastStableVersion}-unstable-${v.date}";
                rawVersion = v.version;
              }
            else
              { rawVersion = v.version; };
        in
        v // baseData // unstableData
    ) sources;

  isBuildable =
    pkg:
    lib.isDerivation pkg
    && !(pkg.meta.broken or false)
    && !(pkg.meta.insecure or false)
    && (lib.meta.availableOn pkgs.stdenv.hostPlatform pkg);
}
