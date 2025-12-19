{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  mylib,
}:

let
  makeBinPackage = mylib.makeBinPackage;

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

in
io_uring_simd
