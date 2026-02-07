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
      storePathVersion =
        if lib.hasPrefix "/nix/store/" v.version then
          let
            pathWithoutPrefix = lib.removePrefix "/nix/store/" v.version;
            shortHash = builtins.substring 0 8 pathWithoutPrefix;
          in
          {
            version = "store-${shortHash}";
          }
        else
          { };
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
      storePathVersion
    ]
) sources
