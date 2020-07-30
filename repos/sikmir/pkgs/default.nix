{ pkgs, sources }:
let
  inherit (pkgs) lib newScope recurseIntoAttrs libsForQt5;
in
lib.makeScope newScope (
  self: with self; {
    inherit sources;

    ### APPLICATIONS

    goldendict-bin = callPackage ./applications/goldendict/bin.nix { };
    gpxlab = libsForQt5.callPackage ./applications/gpxlab {
      inherit sources;
    };
    gpxsee = libsForQt5.callPackage ./applications/gpxsee {
      inherit sources;
    };
    gpxsee-bin = callPackage ./applications/gpxsee/bin.nix { };
    keeweb-bin = callPackage ./applications/keeweb/bin.nix { };
    librewolf = callPackage ./applications/librewolf { };
    macpass-bin = callPackage ./applications/macpass/bin.nix { };
    mapsoft = callPackage ./applications/mapsoft { };
    mapsoft2 = callPackage ./applications/mapsoft/2.nix { };
    nnn-plugins = callPackage ./applications/nnn-plugins { };
    openorienteering-mapper = libsForQt5.callPackage ./applications/openorienteering-mapper {
      inherit sources;
    };
    openorienteering-mapper-bin = callPackage ./applications/openorienteering-mapper/bin.nix { };
    qmapshack-bin = callPackage ./applications/qmapshack/bin.nix { };
    redict = libsForQt5.callPackage ./applications/redict {
      inherit sources;
    };
    visualgps = libsForQt5.callPackage ./applications/visualgps { };
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
    how-to-use-pvs-studio-free = callPackage ./development/tools/pvs-studio/how-to-use-pvs-studio-free.nix { };
    pvs-studio = callPackage ./development/tools/pvs-studio { };

    ### DEVELOPMENT / LIBRARIES

    foma = callPackage ./development/libraries/foma {
      libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
    };
    geographiclib = callPackage ./development/libraries/geographiclib { };
    gpxlib = callPackage ./development/libraries/gpxlib { };
    hfst = callPackage ./development/libraries/hfst { };
    libgarmin = callPackage ./development/libraries/libgarmin {
      automake = pkgs.automake111x;
    };
    libshell = callPackage ./development/libraries/libshell { };
    microjson = callPackage ./development/libraries/microjson { };

    ### DEVELOPMENT / PERL MODULES

    perlPackages = (
      callPackage ./perl-packages.nix { }
    ) // pkgs.perlPackages // {
      recurseForDerivations = false;
    };

    ### DEVELOPMENT / PYTHON MODULES

    cheetah3 = callPackage ./development/python-modules/cheetah3 { };
    click-6-7 = callPackage ./development/python-modules/click { };
    gpxelevations = callPackage ./development/python-modules/gpxelevations { };
    jsonseq = callPackage ./development/python-modules/jsonseq { };
    mercantile = callPackage ./development/python-modules/mercantile { };
    mikatools = callPackage ./development/python-modules/mikatools { };
    pyephem = callPackage ./development/python-modules/pyephem { };
    python-hfst = callPackage ./development/python-modules/python-hfst { };
    pymbtiles = callPackage ./development/python-modules/pymbtiles { };

    ### TOOLS

    cfiles = callPackage ./tools/cfiles { };
    cgpsmapper = callPackage ./tools/geo/cgpsmapper { };
    csvquote = callPackage ./tools/text/csvquote { };
    csvtools = callPackage ./tools/text/csvtools { };
    datamaps = callPackage ./tools/geo/datamaps { };
    docker-reg-tool = callPackage ./tools/docker-reg-tool { };
    elevation = callPackage ./tools/geo/elevation {
      click = click-6-7;
    };
    fx-bin = callPackage ./tools/text/fx/bin.nix { };
    gimgtools = callPackage ./tools/geo/gimgtools { };
    gmaptool = callPackage ./tools/geo/gmaptool { };
    gpx-layer = perlPackages.callPackage ./tools/geo/gpx-layer {
      inherit sources;
    };
    gpxtools = callPackage ./tools/geo/gpxtools { };
    gt-bash-client = callPackage ./tools/dict/gt-bash-client { };
    gt4gd = callPackage ./tools/dict/gt4gd { };
    i18n-editor = callPackage ./tools/i18n-editor { jre = pkgs.jdk11; };
    imgdecode = callPackage ./tools/geo/imgdecode { };
    ish = callPackage ./tools/networking/ish { };
    lsdreader = callPackage ./tools/dict/lsdreader { };
    morse-talk = callPackage ./tools/morse-talk { };
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
    supermercado = callPackage ./tools/geo/supermercado { };
    supload = callPackage ./tools/supload { };
    taginfo-tools = callPackage ./tools/geo/taginfo-tools { };
    tilesets-cli = callPackage ./tools/geo/tilesets-cli { };
    tpkutils = callPackage ./tools/geo/tpkutils { };
    xfractint = callPackage ./tools/xfractint { };

    ### SERVERS

    geminid = callPackage ./servers/geminid { };
    glauth = callPackage ./servers/glauth { };
    mbtileserver = callPackage ./servers/mbtileserver { };
    nakarte = callPackage ./servers/nakarte { };
    pg_tileserv = callPackage ./servers/pg_tileserv { };
    shavit = callPackage ./servers/shavit { };

    ### MISC

    embox = callPackage ./embox { };
  }
)
