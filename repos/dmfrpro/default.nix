# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  spflashtool5 = pkgs.callPackage ./pkgs/spflashtool5 { };
  spflashtool6 = pkgs.callPackage ./pkgs/spflashtool6 { };
  mtk-udev-rules = pkgs.callPackage ./pkgs/mtk-udev-rules { };

  rkflashtool = pkgs.callPackage ./pkgs/rkflashtool { };
  upgrade_tool = pkgs.callPackage ./pkgs/upgrade_tool { };
  rockchip-udev-rules = pkgs.callPackage ./pkgs/rockchip-udev-rules { };

  auroraos-asbt-apptool = pkgs.callPackage ./pkgs/auroraos-asbt-apptool { lib = (import ./lib { inherit pkgs; }); };
  auroraos-platform-sdk = pkgs.callPackage ./pkgs/auroraos-platform-sdk { lib = (import ./lib { inherit pkgs; }); };

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
