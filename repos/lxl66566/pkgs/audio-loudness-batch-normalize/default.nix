{
  stdenv,
  lib,
  pkgs,
  makeBinPackage,
}:

let
  pname = "audio-loudness-batch-normalize";
  bname = "loudness-normalize";
  description = "Easy to use audio loudness batch normalization tool based on EBU R128, written in Rust";

  sourceInfo = lib.importJSON ./source-info.json;
  commonArgs = ({
    inherit
      pname
      bname
      description
      ;
  })
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
