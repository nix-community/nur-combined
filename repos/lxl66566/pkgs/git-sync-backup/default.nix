{
  stdenv,
  lib,
  pkgs,
  makeBinPackage,
}:

let
  pname = "git-sync-backup";
  bname = "gsb";
  description = "Synchronize and backup files/folders using Git, cross-device & configurable.";

  sourceInfo = lib.importJSON ./source-info.json;
  commonArgs = {
    inherit
      pname
      bname
      description
      ;
  }
  // sourceInfo;

  gnu = makeBinPackage (
    commonArgs
    // {
      nixSystem = stdenv.hostPlatform.system;
      libc = "gnu";
    }
  );

  musl = makeBinPackage (
    commonArgs
    // {
      nixSystem = pkgs.stdenv.hostPlatform.system;
      libc = "musl";
      overrideStdenv = pkgs.pkgsStatic.stdenv;
    }
  );

  packages = lib.mapAttrs (
    nixSystem: libcMap:
    lib.mapAttrs (
      libc: _:
      makeBinPackage (
        commonArgs
        // {
          inherit nixSystem libc;
          overrideStdenv = if libc == "musl" then pkgs.pkgsStatic.stdenv else null;
        }
      )
    ) libcMap
  ) sourceInfo.hashes;

in

gnu.overrideAttrs (oldAttrs: {
  passthru = {
    inherit musl packages;
  };
})
