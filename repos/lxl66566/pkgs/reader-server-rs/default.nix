{
  stdenv,
  lib,
  pkgs,
  makeBinPackage,
}:

let
  pname = "reader-server-rs";
  bname = "reader-server";
  description = "A self-hosted reading server for txt/epub books with multi-user progress sync";

  sourceInfo = lib.importJSON ./source-info.json;
  commonArgs = {
    inherit
      pname
      bname
      description
      ;
    license = lib.licenses.bsd3;
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
