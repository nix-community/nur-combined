{ pkgs ? import <nixpkgs> { } }:
rec {
  modules = import ./modules;
  overlays = import ./overlays;

  amcdx-video-patcher-cli = pkgs.callPackage ./pkgs/amcdx-video-patcher-cli { };
  ltfs = pkgs.callPackage ./pkgs/ltfs { };
  vapoursynth-bwdif = pkgs.callPackage ./pkgs/vapoursynth-bwdif { };
  pyhht = pkgs.python3.pkgs.callPackage ./pkgs/pyhht { };
  vhs-decode = pkgs.callPackage ./pkgs/vhs-decode { inherit pyhht; };
}
