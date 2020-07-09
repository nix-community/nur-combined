{ pkgs, sources }:
let
  inherit (pkgs) lib newScope recurseIntoAttrs python3Packages libsForQt5;
in
lib.makeScope newScope (
  self: with self; {
    inherit sources;

    ### APPLICATIONS

    gpxlab = libsForQt5.callPackage ./applications/gpxlab {
      inherit sources;
    };
    gpxsee = libsForQt5.callPackage ./applications/gpxsee {
      inherit sources;
    };
    librewolf = callPackage ./applications/librewolf { };
    macpass = callPackage ./applications/macpass { };
    mapsoft = callPackage ./applications/mapsoft { };
    mapsoft2 = callPackage ./applications/mapsoft/2.nix { };
    nnn-plugins = callPackage ./applications/nnn-plugins { };
    openorienteering-mapper = libsForQt5.callPackage ./applications/openorienteering-mapper {
      inherit sources;
    };
    redict = libsForQt5.callPackage ./applications/redict {
      inherit sources;
    };
    wireguard-statusbar = callPackage ./applications/wireguard-statusbar { };

    ### BUILD SUPPORT

    fetchfromgh = callPackage ./build-support/fetchfromgh { };
    fetchgdrive = callPackage ./build-support/fetchgdrive { };
    fetchwebarchive = callPackage ./build-support/fetchwebarchive { };

    ### DATA

    huzheng = callPackage ./data/dicts/huzheng { };
    wiktionary = callPackage ./data/dicts/wiktionary { };

    gpsmap64 = callPackage ./data/firmwares/gpsmap64 { };

    freizeitkarte-osm = callPackage ./data/maps/freizeitkarte-osm { };
    gpxsee-dem = callPackage ./data/maps/gpxsee-dem { };
    gpxsee-maps = callPackage ./data/maps/gpxsee-maps { };
    gpxsee-poi = callPackage ./data/maps/gpxsee-poi { };
    hiblovgpsmap = callPackage ./data/maps/hiblovgpsmap { };
    maptourist = callPackage ./data/maps/maptourist { };
    mtk-suomi = callPackage ./data/maps/mtk-suomi { };
    opentopomap = callPackage ./data/maps/opentopomap { };
    qmapshack-onlinemaps = callPackage ./data/maps/qmapshack-onlinemaps { };
    qmapshack-routinodb = callPackage ./data/maps/qmapshack-routinodb { };
    qmapshack-dem = callPackage ./data/maps/qmapshack-dem { };
    slazav-hr = callPackage ./data/maps/slazav/hr.nix { };
    slazav-podm = callPackage ./data/maps/slazav/podm.nix { };

    goldendict-dark-theme =
      callPackage ./data/themes/goldendict-themes/dark-theme.nix { };
    qtpbfimageplugin-styles = callPackage ./data/themes/qtpbfimageplugin-styles { };

    ### DEVELOPMENT / TOOLS

    gef = callPackage ./development/tools/gef { };

    ### DEVELOPMENT / LIBRARIES

    foma = callPackage ./development/libraries/foma {
      libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
    };
    geographiclib = callPackage ./development/libraries/geographiclib { };
    hfst = callPackage ./development/libraries/hfst { };
    libgarmin = callPackage ./development/libraries/libgarmin {
      automake = pkgs.automake111x;
    };
    libshell = callPackage ./development/libraries/libshell { };

    ### DEVELOPMENT / PERL MODULES

    perlPackages = (
      callPackage ./perl-packages.nix { }
    ) // pkgs.perlPackages // {
      recurseForDerivations = false;
    };

    ### DEVELOPMENT / PYTHON MODULES

    cheetah3 = python3Packages.callPackage ./development/python-modules/cheetah3 {
      inherit sources;
    };
    click-6-7 = python3Packages.callPackage ./development/python-modules/click { };
    gpxelevations = python3Packages.callPackage ./development/python-modules/gpxelevations {
      inherit sources;
    };
    mercantile = python3Packages.callPackage ./development/python-modules/mercantile {
      inherit sources;
    };
    mikatools = python3Packages.callPackage ./development/python-modules/mikatools {
      inherit sources;
    };
    pyephem = python3Packages.callPackage ./development/python-modules/pyephem {
      inherit sources;
    };
    python-hfst = python3Packages.callPackage ./development/python-modules/python-hfst {
      inherit hfst;
    };
    pymbtiles = python3Packages.callPackage ./development/python-modules/pymbtiles {
      inherit sources;
    };

    ### TOOLS

    cfiles = callPackage ./tools/cfiles { };
    cgpsmapper = callPackage ./tools/geo/cgpsmapper { };
    csvquote = callPackage ./tools/text/csvquote { };
    csvtools = callPackage ./tools/text/csvtools { };
    datamaps = callPackage ./tools/geo/datamaps { };
    docker-reg-tool = callPackage ./tools/docker-reg-tool { };
    elevation = python3Packages.callPackage ./tools/geo/elevation {
      inherit sources;
      click = click-6-7;
    };
    gimgtools = callPackage ./tools/geo/gimgtools { };
    gmaptool = callPackage ./tools/geo/gmaptool { };
    gpx-layer = perlPackages.callPackage ./tools/geo/gpx-layer {
      inherit sources;
    };
    gpxtools = callPackage ./tools/geo/gpxtools { };
    gt-bash-client = callPackage ./tools/dict/gt-bash-client { };
    gt4gd = python3Packages.callPackage ./tools/dict/gt4gd {
      inherit sources;
    };
    i18n-editor = callPackage ./tools/i18n-editor { jre = pkgs.jdk11; };
    imgdecode = callPackage ./tools/geo/imgdecode { };
    ish = callPackage ./tools/networking/ish { };
    lsdreader = python3Packages.callPackage ./tools/dict/lsdreader {
      inherit sources;
    };
    morse-talk = python3Packages.callPackage ./tools/morse-talk {
      inherit sources;
    };
    musig = callPackage ./tools/audio/musig { };
    ocad2img = perlPackages.callPackage ./tools/geo/ocad2img {
      inherit cgpsmapper ocad2mp;
    };
    ocad2mp = callPackage ./tools/geo/ocad2mp { };
    odict = callPackage ./tools/dict/odict { };
    openmtbmap = callPackage ./tools/geo/openmtbmap { };
    osm2mp = perlPackages.callPackage ./tools/geo/osm2mp {
      inherit sources;
      inherit (perlPackages) GeoOpenstreetmapParser MatchSimple MathPolygon MathPolygonTree TreeR;
    };
    ptunnel = callPackage ./tools/networking/ptunnel { };
    sendmap20 = callPackage ./tools/geo/sendmap20 { };
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
    xfractint = callPackage ./tools/xfractint { };

    ### SERVERS

    mbtileserver = callPackage ./servers/mbtileserver { };
    nakarte = callPackage ./servers/nakarte { };
    pg_tileserv = callPackage ./servers/pg_tileserv { };
    shavit = callPackage ./servers/shavit { };

    ### MISC

    embox = callPackage ./embox { };
  }
)
