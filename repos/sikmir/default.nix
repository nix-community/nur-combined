{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let sources = import ./nix/sources.nix;
in {
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
  gpxlab = libsForQt5.callPackage ./pkgs/gpxlab {
    inherit (sources) GPXLab;
  };
  gpxpy = python3Packages.callPackage ./pkgs/gpxpy {
    inherit (sources) gpxpy;
  };
  gpxsee = libsForQt5.callPackage ./pkgs/gpxsee {
    inherit (sources) GPXSee;
  };
  gpxsee-maps = callPackage ./pkgs/gpxsee-maps {
    inherit (sources) GPXSee-maps;
  };
  gpxtools = callPackage ./pkgs/gpxtools {
    inherit (sources) gpxtools;
  };
  gt4gd = python3Packages.callPackage ./pkgs/gt4gd {
    inherit (sources) google-translate-for-goldendict;
  };
  mbutil = python3Packages.callPackage ./pkgs/mbutil {
    inherit (sources) mbutil;
  };
  redict = libsForQt5.callPackage ./pkgs/redict {
    inherit (sources) redict;
  };
  stardict-tools = callPackage ./pkgs/stardict-tools {
    inherit (sources) stardict-3;
  };
}
