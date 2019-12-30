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

  cfiles = callPackage ./pkgs/cfiles {
    inherit ueberzug;
    inherit (sources) cfiles;
  };
  csvquote = callPackage ./pkgs/csvquote {
    inherit (sources) csvquote;
  };
  csvtools = callPackage ./pkgs/csvtools {
    inherit (sources) csvtools;
  };
  datamaps = callPackage ./pkgs/datamaps {
    inherit (sources) datamaps;
  };
  gpx-layer = perlPackages.callPackage ./pkgs/gpx-layer {
    inherit (sources) gpx-layer;
  };
  gpxelevations = python3Packages.callPackage ./pkgs/gpxelevations {
    inherit gpxpy;
    inherit (sources) gpxelevations;
  };
  gpxlab = libsForQt5.callPackage ./pkgs/gpxlab {
    inherit (sources) gpxlab;
  };
  gpxpy = python3Packages.callPackage ./pkgs/gpxpy {
    inherit (sources) gpxpy;
  };
  gpxsee = libsForQt5.callPackage ./pkgs/gpxsee {
    inherit (sources) gpxsee;
  };
  gpxsee-maps = callPackage ./pkgs/gpxsee-maps {
    inherit (sources) gpxsee-maps;
  };
  gpxtools = callPackage ./pkgs/gpxtools {
    inherit (sources) gpxtools;
  };
  lsd2dsl = libsForQt5.callPackage ./pkgs/lsd2dsl {
    inherit (sources) lsd2dsl;
  };
  lsdreader = python3Packages.callPackage ./pkgs/lsdreader {
    inherit (sources) lsdreader;
  };
  gt4gd = python3Packages.callPackage ./pkgs/gt4gd {
    inherit (sources) google-translate-for-goldendict;
  };
  imgp = python3Packages.callPackage ./pkgs/imgp {
    inherit (sources) imgp;
  };
  mapsoft = callPackage ./pkgs/mapsoft {
    inherit (sources) mapsoft;
  };
  mbtileserver = callPackage ./pkgs/mbtileserver {
    inherit (sources) mbtileserver;
  };
  mbutil = python3Packages.callPackage ./pkgs/mbutil {
    inherit (sources) mbutil;
  };
  openorienteering-mapper = libsForQt5.callPackage ./pkgs/openorienteering-mapper {
    inherit (sources) mapper;
  };
  redict = libsForQt5.callPackage ./pkgs/redict {
    inherit (sources) redict;
  };
  stardict-tools =
    # Needed for nixos-19.09
    if pkgs ? libmysql
    then callPackage ./pkgs/stardict-tools {
      inherit (sources) stardict-3;
      libmysqlclient = libmysql;
    }
    else callPackage ./pkgs/stardict-tools {
      inherit (sources) stardict-3;
    };
  supload = callPackage ./pkgs/supload {
    inherit (sources) supload;
  };
  ueberzug = python3Packages.callPackage ./pkgs/ueberzug {
    inherit (sources) ueberzug;
  };
}
