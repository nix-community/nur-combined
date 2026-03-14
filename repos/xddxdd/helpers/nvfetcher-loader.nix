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
        let
          version = v.version or "";
          lastStableVersion =
            if builtins.hasAttr "${n}-stable" sources then
              lib.removePrefix "v" sources."${n}-stable".version
            else
              "0";
        in
        if builtins.match "[0-9]{4}-[0-9]{2}-[0-9]{2}" version != null then
          {
            version = "${lastStableVersion}-unstable-${version}";
            rawVersion = v.version;
          }
        else if (builtins.match "[0-9a-f]{40}" version != null) && (builtins.hasAttr "date" v) then
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
