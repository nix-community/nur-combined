{
  lib,
  callPackage,
  linux,
  mergePkgs,
  fetchpatch,
  ...
}@args:
let
  inherit (callPackage lib/extract.nix { }) extractGridDriver extractVgpuDriver;
  sources = lib.importJSON ./sources.json;

  rcu_patch = fetchpatch {
    url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
    hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
  };

  gridDriver =
    version: source:
    let
      pkg = import lib/grid_base.nix {
        version = source.guest.version;
        src = extractGridDriver version source;
        settingsSha256 = source.guest.settings_hash;
        settingsVersion = source.guest.settings_version;
        persistencedSha256 = source.guest.persistenced_hash;
        persistencedVersion = source.guest.persistenced_version;
        patches = [ rcu_patch ];
      };
    in
    callPackage pkg { kernel = linux; };

  vgpuDriver =
    version: source:
    let
      pkg = import lib/vgpu_base.nix {
        version = source.host.version;
        src = extractVgpuDriver version source;
        settingsSha256 = source.host.settings_hash;
        settingsVersion = source.host.settings_version;
        persistencedSha256 = source.host.persistenced_hash;
        persistencedVersion = source.host.persistenced_version;
        patches = [ rcu_patch ];
      };
    in
    callPackage pkg { kernel = linux; };
in
rec {
  grid = mergePkgs (
    lib.mapAttrs' (
      k: v: lib.nameValuePair (builtins.replaceStrings [ "." ] [ "_" ] k) (gridDriver k v)
    ) sources
  );

  guest = grid;

  vgpu = mergePkgs (
    lib.mapAttrs' (
      k: v: lib.nameValuePair (builtins.replaceStrings [ "." ] [ "_" ] k) (vgpuDriver k v)
    ) sources
  );

  host = vgpu;
}
