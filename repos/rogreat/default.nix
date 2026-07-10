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

rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  amethyst-mod-manager = pkgs.callPackage ./pkgs/amethyst-mod-manager {
    inherit libloot-python;
  };
  crimsondesert-ultimatemodsmanager = pkgs.callPackage ./pkgs/crimsondesert-ultimatemodsmanager {
    inherit privatebin pyside6-fluent-widgets;
  };
  cuprate = pkgs.callPackage ./pkgs/cuprate { };
  customtkinter = pkgs.python3Packages.callPackage ./pkgs/customtkinter { };
  gupax = pkgs.callPackage ./pkgs/gupax {
    inherit cuprate;
  };
  libloot-python = pkgs.python3Packages.callPackage ./pkgs/libloot-python { };
  native-open-mod-manager = pkgs.callPackage ./pkgs/native-open-mod-manager { };
  privatebin = pkgs.python3Packages.callPackage ./pkgs/privatebin { };
  pyside6-fluent-widgets = pkgs.python3Packages.callPackage ./pkgs/pyside6-fluent-widgets {
    inherit pysidesix-frameless-window;
  };
  pysidesix-frameless-window = pkgs.python3Packages.callPackage ./pkgs/pysidesix-frameless-window { };
  sparrow-wifi = pkgs.callPackage ./pkgs/sparrow-wifi { };
  steam-optionx = pkgs.callPackage ./pkgs/steam-optionx { };
}
