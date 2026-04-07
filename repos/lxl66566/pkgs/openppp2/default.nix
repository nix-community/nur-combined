{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  makeBinPackage,
}:

let
  pname = "openppp2";
  bname = "ppp";
  description = "Next-generation security network access technology, providing high-performance Virtual Ethernet tunneling service.";

  sourceInfo = lib.importJSON ./source-info.json;
  commonArgs = {
    inherit
      pname
      bname
      description
      ;
  }
  // sourceInfo;

  io_uring_simd = makeBinPackage (
    commonArgs
    // {
      nixSystem = pkgs.stdenv.hostPlatform.system;
      libc = "io_uring_simd";
    }
  );

  tc = makeBinPackage (
    commonArgs
    // {
      nixSystem = pkgs.stdenv.hostPlatform.system;
      libc = "tc_io_uring_simd";
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
        }
      )
    ) libcMap
  ) sourceInfo.hashes;

in
io_uring_simd.overrideAttrs (oldAttrs: {
  passthru = {
    inherit tc packages;
  };
})
