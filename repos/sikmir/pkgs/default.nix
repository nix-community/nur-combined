{ pkgs, sources }:

let
  inherit (pkgs) lib newScope recurseIntoAttrs python3Packages libsForQt5;

in
lib.makeScope newScope (self: with self; {
  inherit sources;

  cambridge = callPackage ./data/dicts/cambridge { };
  cfiles = callPackage ./tools/cfiles { };
  cgpsmapper = callPackage ./tools/geo/cgpsmapper { };
  cheetah3 = python3Packages.callPackage ./development/python-modules/cheetah3 {
    inherit sources;
  };
  click = python3Packages.callPackage ./development/python-modules/click { };
  csvquote = callPackage ./tools/text/csvquote { };
  csvtools = callPackage ./tools/text/csvtools { };
  datamaps = callPackage ./tools/geo/datamaps { };
  docker-reg-tool = callPackage ./tools/docker-reg-tool { };
  elevation = python3Packages.callPackage ./tools/geo/elevation {
    inherit sources click;
  };
  embox = callPackage ./embox { };
  gimgtools = callPackage ./tools/geo/gimgtools { };
  gmaptool = callPackage ./tools/geo/gmaptool { };
  goldendict-dark-theme =
    callPackage ./data/themes/goldendict-themes/dark-theme.nix { };
  gpx-layer = perlPackages.callPackage ./tools/geo/gpx-layer {
    inherit sources;
  };
  gpxelevations = python3Packages.callPackage ./development/python-modules/gpxelevations {
    inherit sources;
  };
  gpxlab = libsForQt5.callPackage ./applications/gpxlab {
    inherit sources;
  };
  gpxsee = libsForQt5.callPackage ./applications/gpxsee {
    inherit sources;
  };
  gpxsee-maps = callPackage ./data/maps/gpxsee-maps { };
  gpxtools = callPackage ./tools/geo/gpxtools { };
  gt-bash-client = callPackage ./tools/dict/gt-bash-client { };
  lsdreader = python3Packages.callPackage ./tools/dict/lsdreader {
    inherit sources;
  };
  gt4gd = python3Packages.callPackage ./tools/dict/gt4gd {
    inherit sources;
  };
  hiblovgpsmap = callPackage ./data/maps/hiblovgpsmap { };
  ish = callPackage ./tools/networking/ish { };
  libshell = callPackage ./development/libraries/libshell { };
  macmillan = callPackage ./data/dicts/macmillan { };
  mapsoft = callPackage ./applications/mapsoft { };
  mapsoft2 = callPackage ./applications/mapsoft/2.nix { };
  maptourist = callPackage ./data/maps/maptourist { };
  mbtileserver = callPackage ./servers/mbtileserver { };
  mercantile = python3Packages.callPackage ./development/python-modules/mercantile {
    inherit sources;
  };
  openmtbmap_openvelomap_linux = callPackage ./tools/geo/openmtbmap_openvelomap_linux { };
  openorienteering-mapper = libsForQt5.callPackage ./applications/openorienteering-mapper {
    inherit sources;
  };
  osm2mp = perlPackages.callPackage ./tools/geo/osm2mp {
    inherit sources;
    inherit (perlPackages) GeoOpenstreetmapParser MatchSimple MathPolygon MathPolygonTree TreeR;
  };
  ptunnel = callPackage ./tools/networking/ptunnel { };
  pyephem = python3Packages.callPackage ./development/python-modules/pyephem {
    inherit sources;
  };
  pymbtiles = python3Packages.callPackage ./development/python-modules/pymbtiles {
    inherit sources;
  };
  qmapshack-onlinemaps = callPackage ./data/maps/qmapshack-onlinemaps { };
  redict = libsForQt5.callPackage ./applications/redict {
    inherit sources;
  };
  sendmap20 = callPackage ./tools/geo/sendmap20 { };
  slazav-hr = callPackage ./data/maps/slazav/hr.nix { };
  slazav-podm = callPackage ./data/maps/slazav/podm.nix { };
  stardict-tools =
    # Needed for nixos-19.09
    if pkgs ? libmysql
    then callPackage ./tools/dict/stardict-tools {
      libmysqlclient = libmysql;
    }
    else callPackage ./tools/dict/stardict-tools { };
  supermercado = python3Packages.callPackage ./tools/geo/supermercado {
    inherit sources mercantile;
  };
  supload = callPackage ./tools/supload { };
  tpkutils = python3Packages.callPackage ./tools/geo/tpkutils {
    inherit sources mercantile pymbtiles;
  };
  webster = callPackage ./data/dicts/webster { };

  perlPackages = (callPackage ./perl-packages.nix {
  }) // pkgs.perlPackages // {
    recurseForDerivations = false;
  };
  inherit (perlPackages) MatchSimple SubInfix MathPolygon MathPolygonTree MathGeometryPlanarGPCPolygonXS TreeR GeoOpenstreetmapParser;
})
