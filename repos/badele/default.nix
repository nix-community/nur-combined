# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # python3Packages = pkgs.recurseIntoAttrs rec {
  #   simplespectral = pkgs.callPackage ./pkgs/python-modules/simplespectral { };
  #   simplesoapy = pkgs.callPackage ./pkgs/python-modules/simplesoapy { };
  #   soapy_power = pkgs.callPackage ./pkgs/python-modules/soapy_power { inherit simplespectral simplesoapy; };
  #   qtpy = pkgs.callPackage ./pkgs/python-modules/qtpy { };
  #   types-pySide2 = pkgs.callPackage ./pkgs/python-modules/types-pySide2 { };
  #   qspectrumanalyzer = pkgs.callPackage ./pkgs/qspectrumanalyzer { };
  # };

  # SDR
  rtl-gopow = pkgs.callPackage ./pkgs/sdr/rtl-gopow { };
  trunk-recorder = pkgs.callPackage ./pkgs/sdr/trunk-recorder { };
  rtlsdr-airband = pkgs.callPackage ./pkgs/sdr/rtlsdr-airband { };
}
