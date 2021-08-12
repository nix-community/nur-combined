{ pkgs, sources }:
let
  inherit (pkgs) lib newScope recurseIntoAttrs libsForQt5 darwin;
in
lib.makeScope newScope (
  self: with self; {
    inherit sources;

    ### APPLICATIONS

    goldencheetah-bin = callPackage ./applications/goldencheetah/bin.nix { };
    gpxsee-bin = callPackage ./applications/gpxsee/bin.nix { };
    i18n-editor-bin = callPackage ./applications/i18n-editor { jre = pkgs.jdk11; };
    iterm2-bin = callPackage ./applications/iterm2/bin.nix { };
    klogg = libsForQt5.callPackage ./applications/misc/klogg { };
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
    click-6-7 = callPackage ./development/python-modules/click { };
    contextily = callPackage ./development/python-modules/contextily { };
    earthpy = callPackage ./development/python-modules/earthpy { };
    geotiler = callPackage ./development/python-modules/geotiler { };
    gpxelevations = callPackage ./development/python-modules/gpxelevations { };
    jsonseq = callPackage ./development/python-modules/jsonseq { };
    lru-dict = callPackage ./development/python-modules/lru-dict { };
    mikatools = callPackage ./development/python-modules/mikatools { };
    morecantile = callPackage ./development/python-modules/morecantile { };
    portolan = callPackage ./development/python-modules/portolan { };
    pymbtiles = callPackage ./development/python-modules/pymbtiles { };
    python-hfst = callPackage ./development/python-modules/python-hfst { };
    s2sphere = callPackage ./development/python-modules/s2sphere { };
    wikitextprocessor = callPackage ./development/python-modules/wikitextprocessor { };

    ### TOOLS

    datamaps = callPackage ./tools/geo/datamaps { };
    elevation = callPackage ./tools/geo/elevation {
      click = click-6-7;
    };
    go-staticmaps = callPackage ./tools/geo/go-staticmaps { };
    mbtiles2osmand = callPackage ./tools/geo/mbtiles2osmand { };
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
    wiktextract = callPackage ./dict/wiktextract { };
    zdict = callPackage ./dict/zdict { };

    ### EMBOX

    embox-aarch64 = callPackage ./embox { arch = "aarch64"; };
    embox-arm = callPackage ./embox { arch = "arm"; };
    embox-ppc = callPackage ./embox { arch = "ppc"; };
    embox-riscv64 = callPackage ./embox { arch = "riscv64"; };
    embox-x86 = callPackage ./embox {
      stdenv = pkgs.gccMultiStdenv;
    };

    ### GARMIN

    basecamp = callPackage ./garmin/basecamp { };
    cgpsmapper = callPackage ./garmin/cgpsmapper { };
    garmin-uploader = callPackage ./garmin/garmin-uploader { };
    garminimg = libsForQt5.callPackage ./garmin/garminimg { };
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
      inherit (perlPackages) GeoOpenstreetmapParser MatchSimple MathPolygon MathPolygonTree TreeR;
    };
    sendmap20 = callPackage ./garmin/sendmap20 { };

    ### GEMINI

    astronaut = callPackage ./gemini/astronaut { };
    comitium = callPackage ./gemini/comitium { };
    gemget = callPackage ./gemini/gemget { };
    gemini-ipfs-gateway = callPackage ./gemini/gemini-ipfs-gateway { };
    geminid = callPackage ./gemini/geminid { };
    gemreader = callPackage ./gemini/gemreader { };
    gloggery = callPackage ./gemini/gloggery { };
    gmi2html = callPackage ./gemini/gmi2html { };
    gmid = callPackage ./gemini/gmid { };
    gmnhg = callPackage ./gemini/gmnhg { };
    gmnigit = callPackage ./gemini/gmnigit { };
    gssg = callPackage ./gemini/gssg { };
    gurl = callPackage ./gemini/gurl { };
    kineto = callPackage ./gemini/kineto { };
    satellite = callPackage ./gemini/satellite { };
    shavit = callPackage ./gemini/shavit { };
    stargazer = callPackage ./gemini/stargazer {
      inherit (darwin.apple_sdk.frameworks) Security;
    };
    telescope = callPackage ./gemini/telescope { };

    ### GIS

    mapsoft = callPackage ./gis/mapsoft { };
    mapsoft2 = callPackage ./gis/mapsoft/2.nix { };
    qgis-bin = callPackage ./gis/qgis/bin.nix { };
    qgis-ltr-bin = qgis-bin.override { releaseType = "ltr"; };
    qmapshack-bin = callPackage ./gis/qmapshack/bin.nix { };
    sasplanet-bin = callPackage ./gis/sasplanet/bin.nix { };
    tdh = callPackage ./gis/tdh { };

    ### GPX

    cmpgpx = callPackage ./gpx/cmpgpx { };
    gpx-animator = callPackage ./gpx/gpx-animator { };
    gpx-interpolate = callPackage ./gpx/gpx-interpolate { };
    gpx-layer = perlPackages.callPackage ./gpx/gpx-layer { };
    gpxtools = callPackage ./gpx/gpxtools { };
    gpxtrackposter = callPackage ./gpx/gpxtrackposter { };

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
    didder = callPackage ./misc/didder { };
    docker-reg-tool = callPackage ./misc/docker-reg-tool { };
    docx2csv = callPackage ./misc/docx2csv { };
    gef = callPackage ./misc/gef { };
    glauth = callPackage ./misc/glauth { };
    how-to-use-pvs-studio-free = callPackage ./misc/pvs-studio/how-to-use-pvs-studio-free.nix { };
    ish = callPackage ./misc/ish { };
    lazyscraper = callPackage ./misc/lazyscraper { };
    morse-talk = callPackage ./misc/morse-talk { };
    musig = callPackage ./misc/musig { };
    playonmac = callPackage ./misc/playonmac { };
    polyvectorization = libsForQt5.callPackage ./misc/polyvectorization { };
    ptunnel = callPackage ./misc/ptunnel { };
    pvs-studio = callPackage ./misc/pvs-studio { };
    repolocli = callPackage ./misc/repolocli { };
    sdorfehs = callPackage ./misc/sdorfehs { };
    taskcoach = callPackage ./misc/taskcoach { };
    xfractint = callPackage ./misc/xfractint { };
    xtr = callPackage ./misc/xtr {
      inherit (darwin.apple_sdk.frameworks) Foundation;
    };
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
    tracks_storage_server = callPackage ./nakarte/tracks_storage_server { };

    ### OSM

    imposm = callPackage ./osm/imposm { };
    map-stylizer = callPackage ./osm/map-stylizer { };
    maperitive-bin = callPackage ./osm/maperitive/bin.nix { };
    osm-area-tools = callPackage ./osm/osm-area-tools { };
    osmcoastline = callPackage ./osm/osmcoastline { };
    phyghtmap = callPackage ./osm/phyghtmap { };
    roentgen = callPackage ./osm/roentgen { };
    sdlmap = callPackage ./osm/sdlmap { };
    smrender = callPackage ./osm/smrender { };
    taginfo-tools = callPackage ./osm/taginfo-tools { };

    ### RADIO

    airspyhf = callPackage ./radio/airspyhf { };
    libad9361 = callPackage ./radio/libad9361 { };
    sdrpp = callPackage ./radio/sdrpp { };

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
    scc = callPackage ./suckless/scc { };
    scroll = callPackage ./suckless/scroll { };
    sfeed = callPackage ./suckless/sfeed { };
    sfeed_curses = callPackage ./suckless/sfeed_curses { };
    sthkd = callPackage ./suckless/sthkd { };
    xprompt = callPackage ./suckless/xprompt { };
  }
)
