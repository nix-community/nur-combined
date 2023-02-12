# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  
  go-musicfox = pkgs.callPackage ./pkgs/go-musicfox { };
  gtkcord4 = pkgs.callPackage ./pkgs/gtkcord4 { };
  payload-dumper-go = pkgs.callPackage ./pkgs/payload-dumper-go { };
  speedtest-go = pkgs.callPackage ./pkgs/speedtest-go { };
  swww = pkgs.callPackage ./pkgs/swww { };
  fastfetch = pkgs.callPackage ./pkgs/fastfetch { };
  gvim-lily = pkgs.callPackage ./pkgs/gvim-lily { };
  neovim-gtk = pkgs.callPackage ./pkgs/neovim-gtk { };
  yofi = pkgs.callPackage ./pkgs/yofi { };
}
