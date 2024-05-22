{ pkgs, lib, ... }:
sourcesFile:
let
  sources = pkgs.callPackage sourcesFile { };
in
lib.mapAttrs (
  _: v:
  if !(lib.isAttrs v) then
    v
  else
    let
      removeVersionPrefix = {
        version = lib.removePrefix "v" v.version;
      };
      unstableDateVersion =
        if
          (builtins.hasAttr "version" v)
          && (builtins.match "[0-9a-f]{40}" v.version != null)
          && (builtins.hasAttr "date" v)
        then
          { version = "unstable-${v.date}"; }
        else
          { };
    in
    lib.foldl lib.recursiveUpdate v [
      removeVersionPrefix
      unstableDateVersion
    ]
) sources
