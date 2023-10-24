{
  lib,
  callPackage,
  linux,
  ...
} @ args: let
  mergePkgs = callPackage ../../helpers/merge-pkgs.nix {};
  inherit (callPackage lib/extract.nix {}) extractGridDriver extractVgpuDriver;
  sources = lib.importJSON ./sources.json;

  gridDriver = version: source: let
    pkg = import lib/grid_base.nix {
      version = source.guest.version;
      src = extractGridDriver version source;
      settingsSha256 = source.guest.settings_hash;
      settingsVersion = source.guest.settings_version;
      persistencedSha256 = source.guest.persistenced_hash;
      persistencedVersion = source.guest.persistenced_version;
    };
  in
    callPackage pkg {kernel = linux;};

  vgpuDriver = version: source: let
    pkg = import lib/vgpu_base.nix {
      version = source.host.version;
      src = extractVgpuDriver version source;
      settingsSha256 = source.host.settings_hash;
      settingsVersion = source.host.settings_version;
      persistencedSha256 = source.host.persistenced_hash;
      persistencedVersion = source.host.persistenced_version;
    };
  in
    callPackage pkg {kernel = linux;};
in {
  grid = mergePkgs (lib.mapAttrs'
    (k: v:
      lib.nameValuePair
      (builtins.replaceStrings ["."] ["_"] k)
      (gridDriver k v))
    sources);

  vgpu = mergePkgs (lib.mapAttrs'
    (k: v:
      lib.nameValuePair
      (builtins.replaceStrings ["."] ["_"] k)
      (vgpuDriver k v))
    sources);
}
