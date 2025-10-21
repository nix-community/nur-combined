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
  spflashtool-udev-rules = pkgs.callPackage ./pkgs/spflashtool-udev-rules { };

  rkflashtool-fork = pkgs.callPackage ./pkgs/rkflashtool-fork { };
  upgrade_tool = pkgs.callPackage ./pkgs/upgrade_tool { };
  rkflashtool-udev-rules = pkgs.callPackage ./pkgs/rkflashtool-udev-rules { };

  auroraos-asbt-apptool = pkgs.callPackage ./pkgs/auroraos-asbt-apptool { };
  auroraos-platform-sdk = pkgs.callPackage ./pkgs/auroraos-platform-sdk { };

  nix-plugins = pkgs.callPackage ./pkgs/nix-plugins { };

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
