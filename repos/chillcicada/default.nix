{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

{
  lib = import ./lib { inherit lib; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  tokei = callPackage ./pkgs/tokei { inherit (darwin.apple_sdk.frameworks) Security; };
  typship = callPackage ./pkgs/typship { };
  degit-rs = callPackage ./pkgs/degit-rs { };
  tunet-rust = callPackage ./pkgs/tunet-rust { };
  ark-pixel-font = callPackages ./pkgs/ark-pixel-font { };
  clash-verge-rev = callPackage ./pkgs/clash-verge-rev { };
  fusion-pixel-font = callPackages ./pkgs/fusion-pixel-font { };
  wpsoffice-cn = libsForQt5.callPackage ./pkgs/wpsoffice-cn { };
  ttf-ms-win10-sc-sup = callPackage ./pkgs/ttf-ms-win10-sc-sup { };
}
