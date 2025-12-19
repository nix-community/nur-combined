{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  mylib,
  ...
}:

let
  makeBinPackage = mylib.makeBinPackage;

  pname = "fungi";
  bname = "fungi";
  description = "Turn multiple devices into one unified system. A platform built for seamless multi-device integration.";

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
      nixSystem = pkgs.stdenv.hostPlatform.system;
      libc = "gnu";
    }
  );

in
gnu
