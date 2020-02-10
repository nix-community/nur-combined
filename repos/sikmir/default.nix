# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let sources = import ./nix/sources.nix;
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  cfiles = callPackage ./pkgs/tools/cfiles {
    inherit ueberzug;
    inherit (sources) cfiles;
  };
  cheetah3 = python3Packages.callPackage ./pkgs/development/python-modules/cheetah3 {
    inherit (sources) cheetah3;
  };
  click = python3Packages.callPackage ./pkgs/development/python-modules/click { };
  csvquote = callPackage ./pkgs/tools/text/csvquote {
    inherit (sources) csvquote;
  };
  csvtools = callPackage ./pkgs/tools/text/csvtools {
    inherit (sources) csvtools;
  };
  datamaps = callPackage ./pkgs/tools/datamaps {
    inherit (sources) datamaps;
  };
  docker-reg-tool = callPackage ./pkgs/tools/docker-reg-tool {
    inherit (sources) docker-reg-tool;
  };
  elevation = python3Packages.callPackage ./pkgs/tools/elevation {
    inherit click;
    inherit (sources) elevation;
  };
  embox = callPackage ./pkgs/embox {
    inherit (sources) embox;
  };
  gmaptool = callPackage ./pkgs/tools/gmaptool { };
  goldendict-dark-theme =
    callPackage ./pkgs/data/themes/goldendict-themes/dark-theme.nix { };
  gpx-layer = perlPackages.callPackage ./pkgs/tools/gpx-layer {
    inherit (sources) gpx-layer;
  };
  gpxelevations = python3Packages.callPackage ./pkgs/development/python-modules/gpxelevations {
    inherit (sources) gpxelevations;
  };
  gpxlab = libsForQt5.callPackage ./pkgs/applications/gpxlab {
    inherit (sources) gpxlab;
  };
  gpxsee = libsForQt5.callPackage ./pkgs/applications/gpxsee {
    inherit (sources) gpxsee;
  };
  gpxsee-maps = callPackage ./pkgs/data/maps/gpxsee-maps {
    inherit (sources) gpxsee-maps;
  };
  gpxtools = callPackage ./pkgs/tools/gpxtools {
    inherit (sources) gpxtools;
  };
  gt-bash-client = callPackage ./pkgs/tools/gt-bash-client {
    inherit (sources) gt-bash-client;
  };
  lsdreader = python3Packages.callPackage ./pkgs/tools/lsdreader {
    inherit (sources) lsdreader;
  };
  gt4gd = python3Packages.callPackage ./pkgs/tools/gt4gd {
    inherit (sources) google-translate-for-goldendict;
  };
  hiblovgpsmap = callPackage ./pkgs/data/maps/hiblovgpsmap { };
  ish = callPackage ./pkgs/tools/networking/ish { };
  libshell = callPackage ./pkgs/development/libraries/libshell {
    inherit (sources) libshell;
  };
  mapsoft = callPackage ./pkgs/applications/mapsoft {
    inherit libshell;
    inherit (sources) mapsoft;
  };
  mbtileserver = callPackage ./pkgs/servers/mbtileserver {
    inherit (sources) mbtileserver;
  };
  mbutil = python3Packages.callPackage ./pkgs/tools/mbutil {
    inherit (sources) mbutil;
  };
  mercantile = python3Packages.callPackage ./pkgs/development/python-modules/mercantile {
    inherit (sources) mercantile;
  };
  openmtbmap_openvelomap_linux = callPackage ./pkgs/tools/openmtbmap_openvelomap_linux {
    inherit gmaptool;
    inherit (sources) openmtbmap_openvelomap_linux;
  };
  openorienteering-mapper = libsForQt5.callPackage ./pkgs/applications/openorienteering-mapper {
    inherit (sources) mapper;
  };
  ptunnel =  callPackage ./pkgs/tools/networking/ptunnel { };
  pyephem = python3Packages.callPackage ./pkgs/development/python-modules/pyephem {
    inherit (sources) pyephem;
  };
  pymbtiles = python3Packages.callPackage ./pkgs/development/python-modules/pymbtiles {
    inherit (sources) pymbtiles;
  };
  qmapshack-onlinemaps = callPackage ./pkgs/data/maps/qmapshack-onlinemaps { };
  redict = libsForQt5.callPackage ./pkgs/applications/redict {
    inherit (sources) redict;
  };
  stardict-tools =
    # Needed for nixos-19.09
    if pkgs ? libmysql
    then callPackage ./pkgs/tools/stardict-tools {
      inherit (sources) stardict-3;
      libmysqlclient = libmysql;
    }
    else callPackage ./pkgs/tools/stardict-tools {
      inherit (sources) stardict-3;
    };
  supermercado = python3Packages.callPackage ./pkgs/tools/supermercado {
    inherit mercantile;
    inherit (sources) supermercado;
  };
  supload = callPackage ./pkgs/tools/supload {
    inherit (sources) supload;
  };
  tpkutils = python3Packages.callPackage ./pkgs/tools/tpkutils {
    inherit mercantile;
    inherit pymbtiles;
    inherit (sources) tpkutils;
  };
  ueberzug = python3Packages.callPackage ./pkgs/tools/ueberzug {
    inherit (sources) ueberzug;
  };
}
