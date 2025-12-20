{ pkgs, lib, ... }:
sourcesFile:
let
  sources = pkgs.callPackage sourcesFile { };
in
lib.mapAttrs (
  n: v:
  if !(lib.isAttrs v) then
    v
  else
    let
      removeVersionPrefix = {
        version = lib.removePrefix "V" (lib.removePrefix "v" v.version);
      };
      unstableDateVersion =
        if
          (builtins.hasAttr "version" v)
          && (builtins.match "[0-9a-f]{40}" v.version != null)
          && (builtins.hasAttr "date" v)
        then
          let
            lastStableVersion =
              if builtins.hasAttr "${n}-stable" sources then
                lib.removePrefix "v" sources."${n}-stable".version
              else
                "0";
          in
          {
            version = "${lastStableVersion}-unstable-${v.date}";
            rawVersion = v.version;
          }
        else
          { rawVersion = v.version; };
    in
    lib.foldl lib.recursiveUpdate v [
      removeVersionPrefix
      unstableDateVersion
    ]
) sources
