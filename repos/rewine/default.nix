{ pkgs ? import <nixpkgs> { } }:

{
  typora-legacy = pkgs.callPackage ./pkgs/typora-legacy { };
  landrop = pkgs.callPackage ./pkgs/landrop { };
  graphbuilder = pkgs.callPackage ./pkgs/graphbuilder { };
  cmd-markdown = pkgs.callPackage ./pkgs/cmd-markdown { };
  electron-netease-cloud-music = pkgs.callPackage ./pkgs/electron-netease-cloud-music { };
  ttf-wps-fonts = pkgs.callPackage ./pkgs/ttf-wps-fonts { };
  ttf-ms-win10 = pkgs.callPackage ./pkgs/ttf-ms-win10 { };
  lx-music-desktop = pkgs.callPackage ./pkgs/lx-music-desktop { };
  aliyunpan = pkgs.callPackage ./pkgs/aliyunpan { };
  nextssh = pkgs.callPackage ./pkgs/nextssh { };
}
