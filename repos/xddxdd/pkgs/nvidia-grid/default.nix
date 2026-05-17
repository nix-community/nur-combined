{
  lib,
  callPackage,
  linux,
  fetchpatch,
  ...
}:
let
  inherit (callPackage lib/extract.nix { }) extractGridDriver extractVgpuDriver;
  sources = lib.importJSON ./sources.json;

  gridDriver =
    version: source:
    let
      pkg = import lib/grid_base.nix {
        inherit (source.guest) version;
        src = extractGridDriver version source;
        settingsSha256 = source.guest.settings_hash;
        settingsVersion = source.guest.settings_version;
        persistencedSha256 = source.guest.persistenced_hash;
        persistencedVersion = source.guest.persistenced_version;
      };
    in
    callPackage pkg { kernel = linux; };

  vgpuDriver =
    version: source:
    let
      pkg = import lib/vgpu_base.nix {
        inherit (source.host) version;
        src = extractVgpuDriver version source;
        settingsSha256 = source.host.settings_hash;
        settingsVersion = source.host.settings_version;
        persistencedSha256 = source.host.persistenced_hash;
        persistencedVersion = source.host.persistenced_version;
        patches =
          (lib.mapAttrsToList (
            k: v:
            fetchpatch {
              url = k;
              sha256 = v;
            }
          ) source.patches)
          ++ lib.optionals (lib.versionAtLeast version "16.0" && lib.versionOlder version "16.14") [
            ./patches/vfio-16.patch
          ];
      };
    in
    callPackage pkg { kernel = linux; };
in
lib.recurseIntoAttrs (
  lib.mapAttrs (_: lib.recurseIntoAttrs) rec {
    grid = lib.mapAttrs' (
      k: v: lib.nameValuePair (builtins.replaceStrings [ "." ] [ "_" ] k) (gridDriver k v)
    ) sources;
    gridKmod = lib.mapAttrs (k: v: v.mod) grid;

    guest = grid;
    guestKmod = lib.mapAttrs (k: v: v.mod) guest;

    vgpu = lib.mapAttrs' (
      k: v: lib.nameValuePair (builtins.replaceStrings [ "." ] [ "_" ] k) (vgpuDriver k v)
    ) sources;
    vgpuKmod = lib.mapAttrs (k: v: v.mod) vgpu;

    host = vgpu;
    hostKmod = lib.mapAttrs (k: v: v.mod) host;
  }
)
