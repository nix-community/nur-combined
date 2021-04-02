{ pkgs ? import <nixpkgs> { } }:

let
  src = pkgs.fetchzip {
    url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/sosim_v20.zip";
    sha256 = "sha256-HIL2+X+SJkzmsM7nWytNCDURPuPFc5i5tX0o+gGsAbo=";
    stripRoot = false;
  };
  bin = pkgs.wrapWine {
    executable = "${src}/sosim.exe";
    name = "sosim";
  };
  desktop = pkgs.makeDesktopItem {
    name = "sosim";
    desktopName = "SOSIM";
    icon = "utility";
    exec = "${bin}/bin/sosim";
  };
  # in desktop
in
pkgs.symlinkJoin {
  name = "sosim";
  paths = [
    desktop
    bin
  ];
}
