# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Games

  # Themes
  cybergrub2077 = pkgs.callPackage ./pkgs/cybergrub2077 { };

  # Applications
  optiscaler-client = pkgs.callPackage ./pkgs/optiscaler-client { };
  rimsort-appimage = pkgs.callPackage ./pkgs/rimsort-appimage { };
  wowup-cf = pkgs.callPackage ./pkgs/wowup-cf { };

  # Tools
  optipatcher-install = pkgs.callPackage ./pkgs/optipatcher-install { };
  optiscaler-install = pkgs.callPackage ./pkgs/optiscaler-install { };
  scopebuddy = pkgs.callPackage ./pkgs/scopebuddy { };
  # Launcher
  vs-launcher = pkgs.callPackage ./pkgs/vs-launcher { };
}
