{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  mylib,
}:

let
  makeBinPackage = mylib.makeBinPackage;

  pname = "xp3-pack-unpack";
  bname = "xp3-pack-unpack";
  description = "kirikiri xp3 format cli packer & unpacker";

  sourceInfo = lib.importJSON ./source-info.json;
  commonArgs = {
    inherit
      stdenv
      fetchurl
      lib
      pkgs
      pname
      bname
      description
      ;
  }
  // sourceInfo;

  musl = makeBinPackage (
    commonArgs
    // {
      nixSystem = pkgs.stdenv.hostPlatform.system;
      libc = "musl";
      overrideStdenv = pkgs.pkgsStatic.stdenv;
    }
  );

in
musl
