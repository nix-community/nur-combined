# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
   pyPkgs = pkgs.python310.pkgs;
in
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  velociraptor = pkgs.callPackage ./pkgs/velociraptor { };

  # Packages for pyocd
  pypemicro = pyPkgs.callPackage ./pkgs/pypemicro { };
  pyocd-pemicro = pyPkgs.callPackage ./pkgs/pyocd-pemicro {
    inherit pypemicro;
  };
  libusb-package = pyPkgs.callPackage ./pkgs/libusb-package { };
  prettytable25 = pyPkgs.callPackage ./pkgs/prettytable25 { };
  pylink-square012 = pyPkgs.callPackage ./pkgs/pylink-square012 { };
  cmsis-pack-manager = pyPkgs.callPackage ./pkgs/cmsis-pack-manager { };
  pyocd = pyPkgs.callPackage ./pkgs/pyocd {
    inherit pyocd-pemicro;
    inherit libusb-package;
    inherit prettytable25;
    inherit pylink-square012;
    inherit cmsis-pack-manager;
  };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
