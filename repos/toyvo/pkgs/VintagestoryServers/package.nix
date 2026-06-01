{
  callPackage,
  dotnet-runtime_8,
  dotnet-runtime_10,
  lib,
  mono,
  ...
}:
let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  latestVersion = lib.last (builtins.sort lib.versionOlder (builtins.attrNames versions));
  escapeVersion = builtins.replaceStrings [ "." ] [ "_" ];
  getDotnetRuntime =
    version:
    if lib.versionAtLeast version "1.22.0" then
      dotnet-runtime_10
    else if lib.versionAtLeast version "1.18.8" then
      # dotnet-runtime_7 is EOL/insecure in nixpkgs.
      # .NET 8 runtime is backwards compatible with .NET 7 applications.
      dotnet-runtime_8
    else
      mono;
  packages = lib.mapAttrs' (version: value: {
    name = "VintagestoryServer-${escapeVersion version}";
    value = callPackage ./derivation.nix {
      inherit (value) hash url;
      inherit version;
      dotnet-runtime = getDotnetRuntime version;
    };
  }) versions;
in
lib.recurseIntoAttrs (
  packages
  // {
    VintagestoryServer = builtins.getAttr "VintagestoryServer-${escapeVersion latestVersion}" packages;
  }
)
