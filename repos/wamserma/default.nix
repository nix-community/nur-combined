# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
  maintainers = pkgs.lib.maintainers // import ./maintainers.nix;
  mylib = pkgs.lib // { maintainers = maintainers; };
in
let
  python3AppPackages = pkgs.recurseIntoAttrs rec {
    bundlewrap = pkgs.python3.pkgs.callPackage ./pkgs/development/python-modules/bundlewrap { lib = mylib; };
  };
in
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bandit = pkgs.python3.pkgs.toPythonApplication pkgs.python3.pkgs.bandit;
  bundlewrap = pkgs.python3.pkgs.toPythonApplication python3AppPackages.bundlewrap;
  dietlibc = pkgs.callPackage ./pkgs/development/libraries/dietlibc { lib = mylib; };
  encpipe = pkgs.callPackage ./pkgs/tools/security/encpipe { lib = mylib; };
  encpipe-static = pkgs.callPackage ./pkgs/tools/security/encpipe { lib = mylib; static = true; dietlibc = dietlibc; };

  masterpdfeditor4 = pkgs.callPackage pkgs/applications/misc/masterpdfeditor/default.nix { lib = mylib; qtbase = pkgs.qt5.qtbase; qtsvg = pkgs.qt5.qtsvg; wrapQtAppsHook = pkgs.qt5.wrapQtAppsHook; };

  genius-sf-600-firmware = pkgs.callPackage pkgs/misc/firmware/genius/sf600.nix { lib = mylib; };
}

