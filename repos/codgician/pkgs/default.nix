{ pkgs, ... }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // mypkgs);
  mypkgs = {
    aiursoft-tracer = callPackage ./aiursoft-tracer { };
    mtk_uartboot = callPackage ./mtk_uartboot { };
  };
in
mypkgs
