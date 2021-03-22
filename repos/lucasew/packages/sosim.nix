{pkgs ? import <nixpkgs> {}}:
let
  src = pkgs.fetchzip {
    url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/sosim_v11_en.zip";
    sha256 = "sha256-KTsZlDR6AKNjF0TAWeyNyd03DeSB19XRkao5xoq3sBc=";
    stripRoot = false;
  };
  bin = pkgs.writeShellScriptBin "sosim" ''
    ${pkgs.wine}/bin/wine ${src}/sosim.exe "$@"
  '';
  desktop = pkgs.makeDesktopItem {
    name = "sosim";
    desktopName = "SOSIM";
    icon = "utility";
    exec = "${bin}/bin/sosim";
  };
# in desktop
in pkgs.symlinkJoin {
  name = "sosim";
  paths = [
    desktop bin
  ];
}
