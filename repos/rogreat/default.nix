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

  # Python libraries
  python3Packages = rec {
    privatebin = pkgs.python3Packages.callPackage ./pkgs/privatebin { };
    pyside6-fluent-widgets = pkgs.python3Packages.callPackage ./pkgs/pyside6-fluent-widgets {
      inherit pysidesix-frameless-window;
    };
    pysidesix-frameless-window = pkgs.python3Packages.callPackage ./pkgs/pysidesix-frameless-window { };
  };

  # Applications
  crimsondesert-ultimatemodsmanager = pkgs.callPackage ./pkgs/crimsondesert-ultimatemodsmanager {
    inherit (python3Packages) privatebin pyside6-fluent-widgets;
  };
  gupax = pkgs.callPackage ./pkgs/gupax { };
  sparrow-wifi = pkgs.callPackage ./pkgs/sparrow-wifi { };
  steam-optionx = pkgs.callPackage ./pkgs/steam-optionx { };
}
