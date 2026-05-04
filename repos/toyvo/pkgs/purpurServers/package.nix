let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
in
{
  callPackage,
  lib,
  temurin-jre-bin-8,
  temurin-jre-bin-11,
  temurin-jre-bin-17,
  temurin-jre-bin-21,
  temurin-jre-bin-25,
  ...
}:
let
  latestVersion = lib.last (builtins.sort lib.versionOlder (builtins.attrNames versions));
  escapeVersion = builtins.replaceStrings [ "." ] [ "_" ];
  getJre =
    version:
    if lib.versionAtLeast version "26.1" then
      temurin-jre-bin-25
    else if lib.versionAtLeast version "1.20.5" then
      temurin-jre-bin-21
    else if lib.versionAtLeast version "1.18" then
      temurin-jre-bin-17
    else if lib.versionAtLeast version "1.17" then
      temurin-jre-bin-17
    else
      temurin-jre-bin-11;
  packages = lib.mapAttrs' (version: value: {
    name = "purpur-${escapeVersion version}";
    value = callPackage ./derivation.nix {
      inherit (value) version hash;
      jre = getJre version;
    };
  }) versions;
in
lib.recurseIntoAttrs (
  packages
  // {
    purpur = builtins.getAttr "purpur-${escapeVersion latestVersion}" packages;
  }
)
