{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:
rec {
  cmd-markdown = pkgs.callPackage ./pkgs/cmd-markdown { };
  aliyunpan = pkgs.callPackage ./pkgs/aliyunpan { };
  electron-netease-cloud-music = pkgs.callPackage ./pkgs/electron-netease-cloud-music { };
  gammaray = pkgs.callPackage ./pkgs/gammaray { };
  graphbuilder = pkgs.callPackage ./pkgs/graphbuilder { };
  landrop = pkgs.callPackage ./pkgs/landrop { };
  lx-music-desktop = pkgs.callPackage ./pkgs/lx-music-desktop { };
  nextssh = pkgs.callPackage ./pkgs/nextssh { };
  ttf-ms-win10 = pkgs.callPackage ./pkgs/ttf-ms-win10 { };
  ttf-wps-fonts = pkgs.callPackage ./pkgs/ttf-wps-fonts { };
  typora-legacy = pkgs.callPackage ./pkgs/typora-legacy { };
  wiliwili = pkgs.callPackage ./pkgs/wiliwili { };
  wio = pkgs.callPackage ./pkgs/wio { inherit wlroots14; };
  wldbg = pkgs.callPackage ./pkgs/wldbg { };
  wlhax = pkgs.callPackage ./pkgs/wlhax { };
  wlroots14 = pkgs.callPackage ./pkgs/wlroots14 { };
  clazy = pkgs.callPackage ./pkgs/clazy {
    llvmPackages = pkgs.llvmPackages_latest;
    stdenv = pkgs.llvmPackages_latest.stdenv;
  };
}
