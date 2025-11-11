# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  customLib = import ./lib {inherit pkgs;};
  lib = pkgs.lib // customLib;
  callPackage = lib.callPackageWith (pkgs // {inherit lib;});
in {
  # The `lib`, `modules`, and `overlays` names are special
  lib = customLib; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  fzfmenu = callPackage ./pkgs/fzfmenu {};
  moegi-nvim = callPackage ./pkgs/moegi-nvim {};
  winterm-rs = callPackage ./pkgs/winterm-rs {};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
