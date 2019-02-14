{ pkgs ? import <nixpkgs> {} }:

let
  gobject-introspection = pkgs: pkgs.gobject-introspection or pkgs.gobjectIntrospection;
in {
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  beets = pkgs.callPackage ./pkgs/tools/audio/beets {
    pythonPackages = pkgs.python3Packages;
    gobject-introspection = gobject-introspection pkgs;
  };
  dwdiff = pkgs.callPackage ./pkgs/tools/text/dwdiff { };
  ipscan = pkgs.callPackage ./pkgs/applications/networking/ipscan { };
  just = pkgs.callPackage ./pkgs/development/tools/build-managers/just {  };
  lz4json = pkgs.callPackage ./pkgs/tools/compression/lz4json { };
  xcolor = pkgs.callPackage ./pkgs/applications/graphics/xcolor { };
  ydiff = pkgs.pythonPackages.callPackage ./pkgs/tools/text/ydiff { };
}
