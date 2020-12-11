{ pkgs, sources }:
let
  inherit (pkgs) lib newScope recurseIntoAttrs libsForQt5 darwin;
in
lib.makeScope newScope (
  self: with self; {
    inherit sources;

    ### APPLICATIONS

    amethyst-bin = callPackage ./applications/window-managers/amethyst/bin.nix { };
    anki-bin = callPackage ./applications/anki/bin.nix { };
    basecamp = callPackage ./applications/gis/basecamp { };
    goldencheetah-bin = callPackage ./applications/goldencheetah/bin.nix { };
    goldendict-bin = callPackage ./applications/goldendict/bin.nix { };
    gpxlab = libsForQt5.callPackage ./applications/gpxlab {
      inherit sources;
    };
    gpxsee = libsForQt5.callPackage ./applications/gpxsee {
      inherit sources;
    };
    gpxsee-bin = callPackage ./applications/gpxsee/bin.nix { };
    i18n-editor-bin = callPackage ./applications/i18n-editor { jre = pkgs.jdk11; };
    iterm2-bin = callPackage ./applications/iterm2/bin.nix { };
    klogg = libsForQt5.callPackage ./applications/misc/klogg {
      inherit sources;
    };
    klogg-bin = callPackage ./applications/misc/klogg/bin.nix { };
    librewolf = callPackage ./applications/networking/librewolf { };
    macpass-bin = callPackage ./applications/macpass/bin.nix { };
    maperitive-bin = callPackage ./applications/gis/maperitive/bin.nix { };
    mapsoft = callPackage ./applications/gis/mapsoft { };
    mapsoft2 = callPackage ./applications/gis/mapsoft/2.nix { };
    nnn-plugins = callPackage ./applications/nnn-plugins { };
    openorienteering-mapper = libsForQt5.callPackage ./applications/gis/openorienteering-mapper {
      inherit sources;
    };
    openorienteering-mapper-bin = callPackage ./applications/gis/openorienteering-mapper/bin.nix { };
    qgis-bin = callPackage ./applications/gis/qgis/bin.nix { };
    qgis-ltr-bin = qgis-bin.override { releaseType = "ltr"; };
    qmapshack-bin = callPackage ./applications/gis/qmapshack/bin.nix { };
    qutebrowser-bin = callPackage ./applications/networking/qutebrowser/bin.nix { };
    redict = libsForQt5.callPackage ./applications/redict {
      inherit sources;
    };
    sasplanet-bin = callPackage ./applications/gis/sasplanet/bin.nix { };
    tdh = callPackage ./applications/gis/tdh { };
    visualgps = libsForQt5.callPackage ./applications/visualgps { };
    wireguard-statusbar-bin = callPackage ./applications/wireguard-statusbar { };
    yabai = callPackage ./applications/window-managers/yabai {
      inherit (darwin.apple_sdk.frameworks) Cocoa ScriptingBridge;
    };

    ### BUILD SUPPORT

    fetchfromgh = callPackage ./build-support/fetchfromgh { };
    fetchgdrive = callPackage ./build-support/fetchgdrive { };
    fetchwebarchive = callPackage ./build-support/fetchwebarchive { };
    fetchymaps = callPackage ./build-support/fetchymaps { };

    ### DATA

    dadako = callPackage ./data/dicts/dadako { };
    freedict = callPackage ./data/dicts/freedict { };
    huzheng = callPackage ./data/dicts/huzheng { };
    it-sanasto = callPackage ./data/dicts/it-sanasto { };
    wiktionary = callPackage ./data/dicts/wiktionary { };

    gpsmap64 = callPackage ./data/firmwares/gpsmap64 { };

    dem = callPackage ./data/maps/dem { };
    freizeitkarte-osm = callPackage ./data/maps/freizeitkarte-osm { };
    gpxsee-maps = callPackage ./data/maps/gpxsee-maps { };
    vlasenko-maps = callPackage ./data/maps/vlasenko-maps { };
    maptourist = callPackage ./data/maps/maptourist { };
    mtk-suomi = callPackage ./data/maps/mtk-suomi { };
    opentopomap = callPackage ./data/maps/opentopomap { };
    qmapshack-onlinemaps = callPackage ./data/maps/qmapshack-onlinemaps { };
    slazav-hr = callPackage ./data/maps/slazav/hr.nix { };
    slazav-podm = callPackage ./data/maps/slazav/podm.nix { };
    slazav-podm-bin = callPackage ./data/maps/slazav/podm-bin.nix { };
    usa-osm-topo-routable = callPackage ./data/maps/usa-osm-topo-routable { };

    gadm = callPackage ./data/misc/gadm { };
    osm-extracts = callPackage ./data/misc/osm-extracts { };
    poi = callPackage ./data/misc/poi { };
    routinodb = callPackage ./data/misc/routinodb { };

    goldendict-arc-dark-theme =
      callPackage ./data/themes/goldendict-themes/arc-dark-theme.nix { };
    goldendict-dark-theme =
      callPackage ./data/themes/goldendict-themes/dark-theme.nix { };
    qtpbfimageplugin-styles = callPackage ./data/themes/qtpbfimageplugin-styles { };

    ### DEVELOPMENT / TOOLS

    gef = callPackage ./development/tools/gef { };
    kiln = callPackage ./development/tools/kiln { };
    how-to-use-pvs-studio-free = callPackage ./development/tools/pvs-studio/how-to-use-pvs-studio-free.nix { };
    pvs-studio = callPackage ./development/tools/pvs-studio { };
    xtr = callPackage ./development/tools/xtr { };

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

    bson = callPackage ./development/python-modules/bson { };
    cheetah3 = callPackage ./development/python-modules/cheetah3 { };
    click-6-7 = callPackage ./development/python-modules/click { };
    gpxelevations = callPackage ./development/python-modules/gpxelevations { };
    jsonseq = callPackage ./development/python-modules/jsonseq { };
    maprec = callPackage ./development/python-modules/maprec { };
    mercantile = callPackage ./development/python-modules/mercantile { };
    mikatools = callPackage ./development/python-modules/mikatools { };
    ozi_map = callPackage ./development/python-modules/ozi_map { };
    pyephem = callPackage ./development/python-modules/pyephem { };
    pyimagequant = callPackage ./development/python-modules/pyimagequant { };
    pymbtiles = callPackage ./development/python-modules/pymbtiles { };
    python-hfst = callPackage ./development/python-modules/python-hfst { };
    s2sphere = callPackage ./development/python-modules/s2sphere { };
    thinplatespline = callPackage ./development/python-modules/thinplatespline { };

    ### TOOLS

    apibackuper = callPackage ./tools/networking/apibackuper { };
    cfiles = callPackage ./tools/cfiles { };
    cgpsmapper = callPackage ./tools/geo/cgpsmapper { };
    csvquote = callPackage ./tools/text/csvquote { };
    csvtools = callPackage ./tools/text/csvtools { };
    datamaps = callPackage ./tools/geo/datamaps { };
    docker-reg-tool = callPackage ./tools/docker-reg-tool { };
    docx2csv = callPackage ./tools/text/docx2csv { };
    elevation = callPackage ./tools/geo/elevation {
      click = click-6-7;
    };
    fx-bin = callPackage ./tools/text/fx/bin.nix { };
    garmin-uploader = callPackage ./tools/misc/garmin-uploader { };
    gdcv = callPackage ./tools/dict/gdcv { };
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
    gurl = callPackage ./tools/networking/gurl { };
    imgdecode = callPackage ./tools/geo/imgdecode { };
    ish = callPackage ./tools/networking/ish { };
    lazyscraper = callPackage ./tools/text/lazyscraper { };
    lsdreader = callPackage ./tools/dict/lsdreader { };
    map-tiler = callPackage ./tools/geo/map-tiler { };
    morse-talk = callPackage ./tools/morse-talk { };
    musig = callPackage ./tools/audio/musig { };
    ocad2img = perlPackages.callPackage ./tools/geo/ocad2img {
      inherit cgpsmapper ocad2mp fetchwebarchive;
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
    tatoebatools = callPackage ./tools/dict/tatoebatools { };
    tilesets-cli = callPackage ./tools/geo/tilesets-cli { };
    tpkutils = callPackage ./tools/geo/tpkutils { };
    xfractint = callPackage ./tools/xfractint { };
    zdict = callPackage ./tools/dict/zdict { };

    ### GAMES

    ascii-dash = callPackage ./games/ascii-dash { };

    ### SERVERS

    dict2rest = callPackage ./servers/dict2rest { };
    elevation_server = callPackage ./servers/elevation_server { };
    geminid = callPackage ./servers/geminid { };
    glauth = callPackage ./servers/glauth { };
    nakarte = callPackage ./servers/nakarte { };
    quark = callPackage ./servers/quark { };
    shavit = callPackage ./servers/shavit { };

    ### MISC

    embox = callPackage ./embox { };
  }
)
