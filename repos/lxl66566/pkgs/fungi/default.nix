{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  mylib,
}:

let
  makeBinPackage = mylib.makeBinPackage;

  pname = "fungi";
  bname = "fungi";
  description = "Turn multiple devices into one unified system. A platform built for seamless multi-device integration.";

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

  linux = makeBinPackage (
    commonArgs
    // {
      nixSystem = pkgs.stdenv.hostPlatform.system;
      libc = "linux";
    }
  );

in
linux
