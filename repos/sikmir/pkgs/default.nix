{ pkgs, sources }:
let
  inherit (pkgs) lib newScope recurseIntoAttrs libsForQt5 darwin;
in
lib.makeScope newScope (
  self: with self; {
    inherit sources;

    ### APPLICATIONS

    goldencheetah-bin = callPackage ./applications/goldencheetah/bin.nix { };
    gpxlab = libsForQt5.callPackage ./applications/gpxlab {
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
    nnn-plugins = callPackage ./applications/nnn-plugins { };
    openorienteering-mapper-bin = callPackage ./applications/gis/openorienteering-mapper/bin.nix { };
    qutebrowser-bin = callPackage ./applications/networking/qutebrowser/bin.nix { };
    synwrite-bin = callPackage ./applications/synwrite/bin.nix { };
    visualgps = libsForQt5.callPackage ./applications/visualgps { };
    wireguard-statusbar-bin = callPackage ./applications/wireguard-statusbar { };

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
    komputeko = callPackage ./data/dicts/komputeko { };
    tatoeba = callPackage ./data/dicts/tatoeba { };
    wiktionary = callPackage ./data/dicts/wiktionary { };

    gpsmap64 = callPackage ./data/firmwares/gpsmap64 { };

    dem = callPackage ./data/maps/dem { };
    freizeitkarte-osm = callPackage ./data/maps/freizeitkarte-osm { };
    gpxsee-maps = callPackage ./data/maps/gpxsee-maps { };
    vlasenko-maps = callPackage ./data/maps/vlasenko-maps { };
    maptourist = callPackage ./data/maps/maptourist { };
    meridian = callPackage ./data/maps/meridian { };
    mtk-suomi = callPackage ./data/maps/mtk-suomi { };
    opentopomap = callPackage ./data/maps/opentopomap { };
    qmapshack-onlinemaps = callPackage ./data/maps/qmapshack-onlinemaps { };
    slazav-hr = callPackage ./data/maps/slazav/hr.nix { };
    slazav-podm = callPackage ./data/maps/slazav/podm.nix { };
    slazav-podm-bin = callPackage ./data/maps/slazav/podm-bin.nix { };
    uralla = callPackage ./data/maps/uralla { };
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

    ### DEVELOPMENT / LIBRARIES

    foma = callPackage ./development/libraries/foma {
      libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
    };
    geographiclib = callPackage ./development/libraries/geographiclib { };
    gpxlib = callPackage ./development/libraries/gpxlib { };
    hfst = callPackage ./development/libraries/hfst { };
    libshell = callPackage ./development/libraries/libshell { };
    microjson = callPackage ./development/libraries/microjson { };

    ### DEVELOPMENT / PERL MODULES

    perlPackages = (
      callPackage ./perl-packages.nix { }
    ) // pkgs.perlPackages // {
      recurseForDerivations = false;
    };

    ### DEVELOPMENT / PYTHON MODULES

    cjkwrap = callPackage ./development/python-modules/cjkwrap { };
    bson = callPackage ./development/python-modules/bson { };
    cheetah3 = callPackage ./development/python-modules/cheetah3 { };
    click-6-7 = callPackage ./development/python-modules/click { };
    geotiler = callPackage ./development/python-modules/geotiler { };
    gpxelevations = callPackage ./development/python-modules/gpxelevations { };
    jsonseq = callPackage ./development/python-modules/jsonseq { };
    mercantile = callPackage ./development/python-modules/mercantile { };
    mikatools = callPackage ./development/python-modules/mikatools { };
    pyephem = callPackage ./development/python-modules/pyephem { };
    pymbtiles = callPackage ./development/python-modules/pymbtiles { };
    python-hfst = callPackage ./development/python-modules/python-hfst { };
    s2sphere = callPackage ./development/python-modules/s2sphere { };

    ### TOOLS

    cmpgpx = callPackage ./tools/geo/cmpgpx {
      inherit geotiler;
    };
    datamaps = callPackage ./tools/geo/datamaps { };
    elevation = callPackage ./tools/geo/elevation {
      click = click-6-7;
    };
    fx-bin = callPackage ./tools/text/fx/bin.nix { };
    go-staticmaps = callPackage ./tools/geo/go-staticmaps { };
    gpx-interpolate = callPackage ./tools/geo/gpx-interpolate { };
    gpx-layer = perlPackages.callPackage ./tools/geo/gpx-layer { };
    gpxtools = callPackage ./tools/geo/gpxtools { };
    gpxtrackposter = callPackage ./tools/geo/gpxtrackposter { };
    py-staticmaps = callPackage ./tools/geo/py-staticmaps { };
    render_geojson = callPackage ./tools/geo/render_geojson { };
    supermercado = callPackage ./tools/geo/supermercado { };
    tile-stitch = callPackage ./tools/geo/tile-stitch { };
    tilesets-cli = callPackage ./tools/geo/tilesets-cli { };
    tpkutils = callPackage ./tools/geo/tpkutils { };

    ### DICT

    dict2rest = callPackage ./dict/dict2rest { };
    gdcv = callPackage ./dict/gdcv { };
    goldendict-bin = callPackage ./dict/goldendict/bin.nix { };
    gt4gd = callPackage ./dict/gt4gd { };
    gt-bash-client = callPackage ./dict/gt-bash-client { };
    lsdreader = callPackage ./dict/lsdreader { };
    odict = callPackage ./dict/odict { };
    opendict = callPackage ./dict/opendict { };
    redict = libsForQt5.callPackage ./dict/redict { };
    stardict-tools = callPackage ./dict/stardict-tools { };
    tatoebatools = callPackage ./dict/tatoebatools { };
    zdict = callPackage ./dict/zdict { };

    ### EMBOX

    embox = callPackage ./embox { };

    ### GARMIN

    basecamp = callPackage ./garmin/basecamp { };
    cgpsmapper = callPackage ./garmin/cgpsmapper { };
    garmin-uploader = callPackage ./garmin/garmin-uploader { };
    garminimg = libsForQt5.callPackage ./garmin/garminimg {
      inherit sources;
    };
    gimgtools = callPackage ./garmin/gimgtools { };
    gmaptool = callPackage ./garmin/gmaptool { };
    imgdecode = callPackage ./garmin/imgdecode { };
    libgarmin = callPackage ./garmin/libgarmin {
      automake = pkgs.automake111x;
    };
    ocad2img = perlPackages.callPackage ./garmin/ocad2img {
      inherit cgpsmapper ocad2mp fetchwebarchive;
    };
    ocad2mp = callPackage ./garmin/ocad2mp { };
    openmtbmap = callPackage ./garmin/openmtbmap { };
    osm2mp = perlPackages.callPackage ./garmin/osm2mp {
      inherit sources;
      inherit (perlPackages) GeoOpenstreetmapParser MatchSimple MathPolygon MathPolygonTree TreeR;
    };
    sendmap20 = callPackage ./garmin/sendmap20 { };

    ### GEMINI

    geminid = callPackage ./gemini/geminid { };
    gemreader = callPackage ./gemini/gemreader { };
    gloggery = callPackage ./gemini/gloggery { };
    gmi2html = callPackage ./gemini/gmi2html { };
    gmnhg = callPackage ./gemini/gmnhg { };
    gmni = callPackage ./gemini/gmni { };
    gmnigit = callPackage ./gemini/gmnigit { };
    gmnisrv = callPackage ./gemini/gmnisrv { };
    gssg = callPackage ./gemini/gssg { };
    gurl = callPackage ./gemini/gurl { };
    kiln = callPackage ./gemini/kiln { };
    kineto = callPackage ./gemini/kineto { };
    md2gemini = callPackage ./gemini/md2gemini { };
    satellite = callPackage ./gemini/satellite { };
    shavit = callPackage ./gemini/shavit { };

    ### GIS

    mapsoft = callPackage ./gis/mapsoft { };
    mapsoft2 = callPackage ./gis/mapsoft/2.nix { };
    qgis-bin = callPackage ./gis/qgis/bin.nix { };
    qgis-ltr-bin = qgis-bin.override { releaseType = "ltr"; };
    qmapshack-bin = callPackage ./gis/qmapshack/bin.nix { };
    sasplanet-bin = callPackage ./gis/sasplanet/bin.nix { };
    tdh = callPackage ./gis/tdh { };

    ### IMAGES

    dockerImages = {
      agate = callPackage ./images/agate { };
      elevation_server = callPackage ./images/elevation_server { };
      git = callPackage ./images/git {
        git = pkgs.gitMinimal.override {
          perlSupport = false;
          nlsSupport = false;
        };
      };
      gmnisrv = callPackage ./images/gmnisrv { };
      mbtileserver = callPackage ./images/mbtileserver { };
      quark = callPackage ./images/quark { };
      wekan = callPackage ./images/wekan { };
    };

    ### MISC

    aamath = callPackage ./misc/aamath { };
    amethyst-bin = callPackage ./misc/amethyst/bin.nix { };
    apibackuper = callPackage ./misc/apibackuper { };
    ascii-dash = callPackage ./misc/ascii-dash { };
    cfiles = callPackage ./misc/cfiles { };
    csvquote = callPackage ./misc/csvquote { };
    csvtools = callPackage ./misc/csvtools { };
    docker-reg-tool = callPackage ./misc/docker-reg-tool { };
    docx2csv = callPackage ./misc/docx2csv { };
    gef = callPackage ./misc/gef { };
    glauth = callPackage ./misc/glauth { };
    how-to-use-pvs-studio-free = callPackage ./misc/pvs-studio/how-to-use-pvs-studio-free.nix { };
    ht = callPackage ./misc/ht { };
    ish = callPackage ./misc/ish { };
    lazyscraper = callPackage ./misc/lazyscraper { };
    morse-talk = callPackage ./misc/morse-talk { };
    musig = callPackage ./misc/musig { };
    playonmac = callPackage ./misc/playonmac { };
    polyvectorization = libsForQt5.callPackage ./misc/polyvectorization {
      inherit sources;
    };
    ptunnel = callPackage ./misc/ptunnel { };
    pvs-studio = callPackage ./misc/pvs-studio { };
    taskcoach = callPackage ./misc/taskcoach { };
    xfractint = callPackage ./misc/xfractint { };
    xtr = callPackage ./misc/xtr { };
    yabai = callPackage ./misc/yabai {
      inherit (darwin.apple_sdk.frameworks) Cocoa ScriptingBridge;
    };

    ### NAKARTE

    elevation_server = callPackage ./nakarte/elevation_server { };
    map-tiler = callPackage ./nakarte/map-tiler { };
    maprec = callPackage ./nakarte/maprec { };
    nakarte = callPackage ./nakarte/nakarte { };
    ozi_map = callPackage ./nakarte/ozi_map { };
    pyimagequant = callPackage ./nakarte/pyimagequant { };
    thinplatespline = callPackage ./nakarte/thinplatespline { };

    ### OSM

    map-stylizer = callPackage ./osm/map-stylizer { };
    maperitive-bin = callPackage ./osm/maperitive/bin.nix { };
    osm-area-tools = callPackage ./osm/osm-area-tools { };
    osmcoastline = callPackage ./osm/osmcoastline { };
    phyghtmap = callPackage ./osm/phyghtmap { };
    sdlmap = callPackage ./osm/sdlmap { };
    taginfo-tools = callPackage ./osm/taginfo-tools { };

    ### SUCKLESS

    blind = callPackage ./suckless/blind { };
    farbfeld-utils = callPackage ./suckless/farbfeld-utils { };
    hurl = callPackage ./suckless/hurl { };
    imscript = callPackage ./suckless/imscript { };
    lacc = callPackage ./suckless/lacc { };
    lel = callPackage ./suckless/lel { };
    quark = callPackage ./suckless/quark { };
    saait = callPackage ./suckless/saait { };
    sbase = callPackage ./suckless/sbase { };
    scroll = callPackage ./suckless/scroll { };
    sfeed = callPackage ./suckless/sfeed { };
    sfm = callPackage ./suckless/sfm { };
    xprompt = callPackage ./suckless/xprompt { };
  }
)
