{ pkgs, sources }:
let
  inherit (pkgs) lib newScope recurseIntoAttrs libsForQt5;
in
lib.makeScope newScope (
  self: with self; {
    inherit sources;

    ### APPLICATIONS

    anki-bin = callPackage ./applications/anki/bin.nix { };
    basecamp = callPackage ./applications/basecamp { };
    goldencheetah-bin = callPackage ./applications/goldencheetah/bin.nix { };
    goldendict-bin = callPackage ./applications/goldendict/bin.nix { };
    gpxlab = libsForQt5.callPackage ./applications/gpxlab {
      inherit sources;
    };
    gpxsee = libsForQt5.callPackage ./applications/gpxsee {
      inherit sources;
    };
    gpxsee-bin = callPackage ./applications/gpxsee/bin.nix { };
    iterm2-bin = callPackage ./applications/iterm2/bin.nix { };
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
    qgis-bin = callPackage ./applications/qgis/bin.nix { };
    qgis-ltr-bin = qgis-bin.override { releaseType = "ltr"; };
    qmapshack-bin = callPackage ./applications/qmapshack/bin.nix { };
    qutebrowser-bin = callPackage ./applications/qutebrowser/bin.nix { };
    qvge = libsForQt5.callPackage ./applications/qvge {
      inherit sources;
    };
    redict = libsForQt5.callPackage ./applications/redict {
      inherit sources;
    };
    sasplanet = callPackage ./applications/sasplanet { };
    tdh = callPackage ./applications/tdh { };
    visualgps = libsForQt5.callPackage ./applications/visualgps { };
    wireguard-statusbar = callPackage ./applications/wireguard-statusbar { };

    ### BUILD SUPPORT

    fetchfromgh = callPackage ./build-support/fetchfromgh { };
    fetchgdrive = callPackage ./build-support/fetchgdrive { };
    fetchwebarchive = callPackage ./build-support/fetchwebarchive { };

    ### DATA

    freedict = callPackage ./data/dicts/freedict { };
    huzheng = callPackage ./data/dicts/huzheng { };
    it-sanasto = callPackage ./data/dicts/it-sanasto { };
    wiktionary = callPackage ./data/dicts/wiktionary { };

    gpsmap64 = callPackage ./data/firmwares/gpsmap64 { };

    dem = callPackage ./data/maps/dem { };
    freizeitkarte-osm = callPackage ./data/maps/freizeitkarte-osm { };
    gpxsee-maps = callPackage ./data/maps/gpxsee-maps { };
    gpxsee-poi = callPackage ./data/maps/gpxsee-poi { };
    hiblovgpsmap = callPackage ./data/maps/hiblovgpsmap { };
    maptourist = callPackage ./data/maps/maptourist { };
    mtk-suomi = callPackage ./data/maps/mtk-suomi { };
    opentopomap = callPackage ./data/maps/opentopomap { };
    qmapshack-onlinemaps = callPackage ./data/maps/qmapshack-onlinemaps { };
    routinodb = callPackage ./data/maps/routinodb { };
    slazav-hr = callPackage ./data/maps/slazav/hr.nix { };
    slazav-podm = callPackage ./data/maps/slazav/podm.nix { };
    slazav-podm-bin = callPackage ./data/maps/slazav/podm-bin.nix { };

    goldendict-dark-theme =
      callPackage ./data/themes/goldendict-themes/dark-theme.nix { };
    qtpbfimageplugin-styles = callPackage ./data/themes/qtpbfimageplugin-styles { };

    ### DEVELOPMENT / TOOLS

    gef = callPackage ./development/tools/gef { };
    kiln = callPackage ./development/tools/kiln { };
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
    pymbtiles = callPackage ./development/python-modules/pymbtiles { };
    python-hfst = callPackage ./development/python-modules/python-hfst { };
    s2sphere = callPackage ./development/python-modules/s2sphere { };

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
    garmin-uploader = callPackage ./tools/misc/garmin-uploader { };
    gimgtools = callPackage ./tools/geo/gimgtools { };
    gloggery = callPackage ./tools/misc/gloggery { };
    gmaptool = callPackage ./tools/geo/gmaptool { };
    go-staticmaps = callPackage ./tools/geo/go-staticmaps { };
    gpx-layer = perlPackages.callPackage ./tools/geo/gpx-layer {
      inherit sources;
    };
    gpxtools = callPackage ./tools/geo/gpxtools { };
    gpxtrackposter = callPackage ./tools/geo/gpxtrackposter { };
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
    phyghtmap = callPackage ./tools/geo/phyghtmap { };
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
    supload = callPackage ./tools/misc/supload { };
    taginfo-tools = callPackage ./tools/geo/taginfo-tools { };
    tilesets-cli = callPackage ./tools/geo/tilesets-cli { };
    tpkutils = callPackage ./tools/geo/tpkutils { };
    xfractint = callPackage ./tools/xfractint { };
    zdict = callPackage ./tools/dict/zdict { };

    ### GAMES

    ascii-dash = callPackage ./games/ascii-dash { };

    ### SERVERS

    dict2rest = callPackage ./servers/dict2rest { };
    geminid = callPackage ./servers/geminid { };
    glauth = callPackage ./servers/glauth { };
    mbtileserver = callPackage ./servers/mbtileserver { };
    nakarte = callPackage ./servers/nakarte { };
    pg_featureserv = callPackage ./servers/pg_featureserv { };
    quark = callPackage ./servers/quark { };
    shavit = callPackage ./servers/shavit { };

    ### MISC

    embox = callPackage ./embox { };
  }
)
