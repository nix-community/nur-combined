# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  old = {
    airnef = pkgs.callPackage ./pkgs/airnef {
      pythonPackages = pkgs.python3Packages;
      buildPythonApplication = pkgs.python3Packages.buildPythonApplication;
    };
    cc-tool = pkgs.callPackage ./pkgs/cc-tool {};
    dump1090-hptoa = pkgs.callPackage ./pkgs/dump1090-hptoa {};
    extplane-panel = pkgs.libsForQt5.callPackage ./pkgs/extplane-panel {};
    implicitcad = pkgs.haskellPackages.callPackage ./pkgs/implicitcad {};
    ipbt = pkgs.callPackage ./pkgs/ipbt {};
    airscan = pkgs.callPackage ./pkgs/airscan {};
    nix-search = pkgs.callPackage ./pkgs/nix-search {};
    sc3-plugins = pkgs.callPackage ./pkgs/sc3-plugins {};
  };

  # copy of dependencies that are not available on older nixos channels
  deps = {
    cereal = pkgs.callPackage ./pkgs/cereal {};
    cgal_5 = pkgs.callPackage ./pkgs/prusa-slicer-latest/cgal_5.nix {};
  };

  joplin-desktop = ( pkgs.callPackage ./pkgs/joplin-desktop {} ).overrideAttrs( _: {
      preferLocalBuild = true;
    }
  );
}
