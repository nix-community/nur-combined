let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
in
{ callPackage, lib, ... }:
let
  latestVersion = lib.last (builtins.sort lib.versionOlder (builtins.attrNames versions));
  escapeVersion = builtins.replaceStrings [ "." ] [ "_" ];
  packages = lib.mapAttrs' (version: value: {
    name = "VintagestoryServer-${escapeVersion version}";
    value = callPackage ./derivation.nix {
      inherit (value) hash url;
      inherit version;
    };
  }) versions;
in
lib.recurseIntoAttrs (
  packages
  // {
    VintagestoryServer = builtins.getAttr "VintagestoryServer-${escapeVersion latestVersion}" packages;
  }
)
