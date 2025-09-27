{ pkgs }:
let
  inherit (pkgs)
    lib
    newScope
    recurseIntoAttrs
    libsForQt5
    darwin
    ;
in
lib.makeScope newScope (
  self: with self; {

    # VSCODE EXTENSIONS

    vscode-extensions = recurseIntoAttrs (callPackage ./vscode-extensions { });

    ### APPLICATIONS

    goldencheetah-bin = callPackage ./applications/goldencheetah/bin.nix { };
    klogg = libsForQt5.callPackage ./applications/misc/klogg { };
    klogg-bin = callPackage ./applications/misc/klogg/bin.nix { };
    synwrite = callPackage ./applications/synwrite { };

    ### BUILD SUPPORT

    fetchfromgh = callPackage ./build-support/fetchfromgh { };
    fetchgdrive = callPackage ./build-support/fetchgdrive { };
    fetchwebarchive = callPackage ./build-support/fetchwebarchive { };
    fetchymaps = callPackage ./build-support/fetchymaps { };

    ### DARWIN

    amethyst = callPackage ./darwin/amethyst { };
    cudatext-bin = callPackage ./darwin/cudatext/bin.nix { };
    darktable-bin = callPackage ./darwin/darktable/bin.nix { };
    finch = callPackage ./darwin/finch { };
    macpass = callPackage ./darwin/macpass { };
    macsvg = callPackage ./darwin/macsvg { };
    marta = callPackage ./darwin/marta { };
    pinentry-touchid = callPackage ./darwin/pinentry-touchid { };
    podman-desktop-bin = callPackage ./darwin/podman-desktop/bin.nix { };
    qtcreator-bin = callPackage ./darwin/qtcreator/bin.nix { };
    sequel-ace = callPackage ./darwin/sequel-ace { };
    zed-preview = callPackage ./darwin/zed { };

    ### DATA

    dadako = callPackage ./data/dicts/dadako { };
    freedict = callPackage ./data/dicts/freedict { };
    huzheng = callPackage ./data/dicts/huzheng { };
    it-sanasto = callPackage ./data/dicts/it-sanasto { };
    komputeko = callPackage ./data/dicts/komputeko { };
    libredict = callPackage ./data/dicts/libredict { };
    tatoeba = callPackage ./data/dicts/tatoeba { };

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
    slazav-fi = callPackage ./data/maps/slazav/fi.nix { };
    uralla = callPackage ./data/maps/uralla { };

    poi = callPackage ./data/misc/poi { };

    osm-extracts = callPackage ./data/osm/osm-extracts { };
    overpassdb = callPackage ./data/osm/overpassdb { };
    routinodb = callPackage ./data/osm/routinodb { };

    goldendict-arc-dark-theme = callPackage ./data/themes/goldendict-themes/arc-dark-theme.nix { };
    goldendict-dark-theme = callPackage ./data/themes/goldendict-themes/dark-theme.nix { };
    qtpbfimageplugin-styles = callPackage ./data/themes/qtpbfimageplugin-styles { };

    ### DEVELOPMENT / LIBRARIES

    iso15765-canbus = callPackage ./development/libraries/iso15765-canbus { };
    isotp-c = callPackage ./development/libraries/isotp-c { };
    jsontoolkit = callPackage ./development/libraries/jsontoolkit { };
    libshell = callPackage ./development/libraries/libshell { };
    libsockcanpp = callPackage ./development/libraries/libsockcanpp { };
    microjson = callPackage ./development/libraries/microjson { };

    ### DEVELOPMENT / PERL MODULES

    perlPackages =
      (callPackage ./perl-packages.nix { }) // pkgs.perlPackages // { recurseForDerivations = false; };

    ### DEVELOPMENT / PYTHON MODULES

    bounded-pool-executor = callPackage ./development/python-modules/bounded-pool-executor { };
    click-6-7 = callPackage ./development/python-modules/click { };
    config-path = callPackage ./development/python-modules/config-path { };
    contextily = callPackage ./development/python-modules/contextily { };
    curses-menu = callPackage ./development/python-modules/curses-menu { };
    earthaccess = callPackage ./development/python-modules/earthaccess { };
    earthpy = callPackage ./development/python-modules/earthpy { };
    geoip2fast = callPackage ./development/python-modules/geoip2fast { };
    geotiler = callPackage ./development/python-modules/geotiler { };
    gpxelevations = callPackage ./development/python-modules/gpxelevations { };
    hardpy = callPackage ./development/python-modules/hardpy { };
    jsonseq = callPackage ./development/python-modules/jsonseq { };
    portolan = callPackage ./development/python-modules/portolan { };
    pqdm = callPackage ./development/python-modules/pqdm { };
    pyarrow_ops = callPackage ./development/python-modules/pyarrow_ops { };
    pycouchdb = callPackage ./development/python-modules/pycouchdb { };
    pymbtiles = callPackage ./development/python-modules/pymbtiles { };
    pytest-docker-fixtures = callPackage ./development/python-modules/pytest-docker-fixtures { };
    pytest-mp = callPackage ./development/python-modules/pytest-mp { };
    pytest-shell-utilities = callPackage ./development/python-modules/pytest-shell-utilities { };
    pytest-skip-markers = callPackage ./development/python-modules/pytest-skip-markers { };
    python-cmr = callPackage ./development/python-modules/python-cmr { };
    s2sphere = callPackage ./development/python-modules/s2sphere { };
    tinynetrc = callPackage ./development/python-modules/tinynetrc { };

    ### EMBEDDED

    chdk = callPackage ./embedded/chdk { };
    embox-aarch64 = callPackage ./embedded/embox { arch = "aarch64"; };
    embox-arm = callPackage ./embedded/embox { arch = "arm"; };
    embox-ppc = callPackage ./embedded/embox { arch = "ppc"; };
    embox-riscv64 = callPackage ./embedded/embox { arch = "riscv64"; };
    embox-x86 = callPackage ./embedded/embox { stdenv = pkgs.gccMultiStdenv; };

    ### GARMIN

    basecamp = callPackage ./garmin/basecamp { };
    cgpsmapper = callPackage ./garmin/cgpsmapper { };
    garmin-uploader = callPackage ./garmin/garmin-uploader { };
    garminimg = libsForQt5.callPackage ./garmin/garminimg { };
    gimgtools = callPackage ./garmin/gimgtools { };
    gmaptool = callPackage ./garmin/gmaptool { };
    imgdecode = callPackage ./garmin/imgdecode { };
    libgarmin = callPackage ./garmin/libgarmin { };
    ocad2img = perlPackages.callPackage ./garmin/ocad2img {
      inherit cgpsmapper ocad2mp fetchwebarchive;
    };
    ocad2mp = callPackage ./garmin/ocad2mp { };
    openmtbmap = callPackage ./garmin/openmtbmap { };
    osm2mp = perlPackages.callPackage ./garmin/osm2mp {
      inherit (perlPackages)
        GeoOpenstreetmapParser
        MatchSimple
        MathPolygon
        MathPolygonTree
        TreeR
        ;
    };
    py-patcher = callPackage ./garmin/py-patcher { };
    sendmap20 = callPackage ./garmin/sendmap20 { };

    ### GEMINI

    agunua = callPackage ./gemini/agunua { };
    astronaut = callPackage ./gemini/astronaut { };
    comitium = callPackage ./gemini/comitium { };
    egemi = callPackage ./gemini/egemi { };
    estampa = callPackage ./gemini/estampa { };
    eva = callPackage ./gemini/eva { };
    gelim = callPackage ./gemini/gelim { };
    gem = callPackage ./gemini/gem { };
    gemcert = callPackage ./gemini/gemcert { };
    gemgen = callPackage ./gemini/gemgen { };
    gemini-ipfs-gateway = callPackage ./gemini/gemini-ipfs-gateway { };
    geminid = callPackage ./gemini/geminid { };
    gemreader = callPackage ./gemini/gemreader { };
    gemserv = callPackage ./gemini/gemserv { };
    gloggery = callPackage ./gemini/gloggery { };
    gmi2html = callPackage ./gemini/gmi2html { };
    gmnhg = callPackage ./gemini/gmnhg { };
    gmnigit = callPackage ./gemini/gmnigit { };
    gplaces = callPackage ./gemini/gplaces { };
    gurl = callPackage ./gemini/gurl { };
    kineto = callPackage ./gemini/kineto { };
    mdtohtml = callPackage ./gemini/mdtohtml { };
    py-gmi2html = callPackage ./gemini/py-gmi2html { };
    qute-gemini = callPackage ./gemini/qute-gemini { };
    satellite = callPackage ./gemini/satellite { };
    shavit = callPackage ./gemini/shavit { };
    stagit-gemini-milotier = callPackage ./gemini/stagit-gemini/milotier.nix { };
    stagit-gemini-sloum = callPackage ./gemini/stagit-gemini/sloum.nix { };
    tom = callPackage ./gemini/tom { };
    twins = callPackage ./gemini/twins { };

    ### GEOSPATIAL

    arcgis2geojson = callPackage ./geospatial/arcgis2geojson { };
    bbox = callPackage ./geospatial/bbox { };
    cassini = callPackage ./geospatial/cassini { };
    c2cwsgiutils = callPackage ./geospatial/c2cwsgiutils { };
    cmocean = callPackage ./geospatial/cmocean { };
    cogdumper = callPackage ./geospatial/cogdumper { };
    cogeo-mosaic = callPackage ./geospatial/cogeo-mosaic { };
    datamaps = callPackage ./geospatial/datamaps { };
    deegree = callPackage ./geospatial/deegree { };
    elevation = callPackage ./geospatial/elevation { click = click-6-7; };
    garmindev = callPackage ./geospatial/qlandkartegt/garmindev.nix { };
    geojson-pydantic = callPackage ./geospatial/geojson-pydantic { };
    geoutils = callPackage ./geospatial/geoutils { };
    geowebcache = callPackage ./geospatial/geowebcache { };
    go-staticmaps = callPackage ./geospatial/go-staticmaps { };
    hecate = callPackage ./geospatial/hecate { };
    kealib = callPackage ./geospatial/kealib { };
    localtileserver = callPackage ./geospatial/localtileserver { };
    mapsoft = callPackage ./geospatial/mapsoft { proj = pkgs.proj_7; };
    mapsoft2 = callPackage ./geospatial/mapsoft/2.nix { };
    mbtiles2osmand = callPackage ./geospatial/mbtiles2osmand { };
    mbutiles = callPackage ./geospatial/mbutiles { };
    orbisgis = callPackage ./geospatial/orbisgis { jre = pkgs.jre8; };
    ossim = callPackage ./geospatial/ossim { };
    pipfile = callPackage ./geospatial/pipfile { };
    pmtiles = callPackage ./geospatial/pmtiles { };
    polyvectorization = libsForQt5.callPackage ./geospatial/polyvectorization { };
    py-staticmaps = callPackage ./geospatial/py-staticmaps { };
    pysheds = callPackage ./geospatial/pysheds { };
    qlandkartegt = libsForQt5.callPackage ./geospatial/qlandkartegt {
      gdal = pkgs.gdal.override {
        libgeotiff = pkgs.libgeotiff.override { proj = pkgs.proj_7; };
        libspatialite = pkgs.libspatialite.override { proj = pkgs.proj_7; };
        proj = pkgs.proj_7;
      };
      proj = pkgs.proj_7;
      inherit garmindev;
    };
    render_geojson = callPackage ./geospatial/render_geojson { wxGTK = pkgs.wxGTK32; };
    rio-cogeo = callPackage ./geospatial/rio-cogeo { };
    rio-color = callPackage ./geospatial/rio-color { };
    rio-mbtiles = callPackage ./geospatial/rio-mbtiles { };
    rio-mucho = callPackage ./geospatial/rio-mucho { };
    rio-stac = callPackage ./geospatial/rio-stac { };
    riverrem = callPackage ./geospatial/riverrem { };
    rsgislib = callPackage ./geospatial/rsgislib { };
    sasplanet = callPackage ./geospatial/sasplanet { };
    server-thread = callPackage ./geospatial/server-thread { };
    starlette-cramjam = callPackage ./geospatial/starlette-cramjam { };
    supermercado = callPackage ./geospatial/supermercado { };
    supermorecado = callPackage ./geospatial/supermorecado { };
    taudem = callPackage ./geospatial/taudem { };
    #tdh = callPackage ./geospatial/tdh { };
    terracotta = callPackage ./geospatial/terracotta { };
    tile-stitch = callPackage ./geospatial/tile-stitch { };
    tilekiln = callPackage ./geospatial/tilekiln { };
    tilesets-cli = callPackage ./geospatial/tilesets-cli { };
    tpkutils = callPackage ./geospatial/tpkutils { };
    tuiview = callPackage ./geospatial/tuiview { };
    vt2geojson = callPackage ./geospatial/vt2geojson { };
    titiler = callPackage ./geospatial/titiler { };
    tilecloud = callPackage ./geospatial/tilecloud { };
    wms-tiles-downloader = callPackage ./geospatial/wms-tiles-downloader { };

    ### GNSS

    gnsstk = callPackage ./gnss/gnsstk { };
    gnsstk-apps = callPackage ./gnss/gnsstk-apps { };
    gps-sdr-sim = callPackage ./gnss/gps-sdr-sim { };
    gpsdate = callPackage ./gnss/gpsdate { };
    pygnssutils = callPackage ./gnss/pygnssutils { };
    pygpsclient = callPackage ./gnss/pygpsclient { };
    pyrtcm = callPackage ./gnss/pyrtcm { };
    pysbf2 = callPackage ./gnss/pysbf2 { };
    pyspartn = callPackage ./gnss/pyspartn { };
    pyubx2 = callPackage ./gnss/pyubx2 { };
    pyubxutils = callPackage ./gnss/pyubxutils { };
    rtklib = callPackage ./gnss/rtklib { };
    rtklib-demo5 = callPackage ./gnss/rtklib/demo5.nix { };
    visualgps = libsForQt5.callPackage ./gnss/visualgps { };

    ### GPX

    cmpgpx = callPackage ./gpx/cmpgpx { };
    fitdecode = callPackage ./gpx/fitdecode { };
    garta = callPackage ./gpx/garta { };
    geojson2dm = callPackage ./gpx/geojson2dm { };
    gprox = callPackage ./gpx/gprox { };
    gps-whatsnew = callPackage ./gpx/gps-whatsnew { };
    gpx-cmd-tools = callPackage ./gpx/gpx-cmd-tools { };
    gpx-converter = callPackage ./gpx/gpx-converter { };
    gpx-interpolate = callPackage ./gpx/gpx-interpolate { };
    gpx-layer = perlPackages.callPackage ./gpx/gpx-layer { };
    gpx-player = callPackage ./gpx/gpx-player { };
    gpx2video = callPackage ./gpx/gpx2video { };
    gpx2yaml = callPackage ./gpx/gpx2yaml { };
    gpxchart = callPackage ./gpx/gpxchart { };
    gpxeditor = callPackage ./gpx/gpxeditor { };
    gpxgo = callPackage ./gpx/gpxgo { };
    gpxlib = callPackage ./gpx/gpxlib { };
    gpxtools = callPackage ./gpx/gpxtools { };
    gpxtrackposter = callPackage ./gpx/gpxtrackposter { };
    routeconverter = callPackage ./gpx/routeconverter { };
    trackanimation = callPackage ./gpx/trackanimation { };

    ### IMAGES

    dockerImages = {
      agate = callPackage ./images/agate { };
      elevation-server = callPackage ./images/elevation-server { };
      git = callPackage ./images/git {
        git = pkgs.gitMinimal.override {
          perlSupport = false;
          nlsSupport = false;
        };
      };
      mbtileserver = callPackage ./images/mbtileserver { };
      quark = callPackage ./images/quark { };
    };

    ### LINGUISTICS

    dict2rest = callPackage ./linguistics/dict2rest { };
    distance = callPackage ./linguistics/distance { };
    gdcv = callPackage ./linguistics/gdcv { };
    goldendict-bin = callPackage ./linguistics/goldendict/bin.nix { };
    gt-bash-client = callPackage ./linguistics/gt-bash-client { };
    gt4gd = callPackage ./linguistics/gt4gd { };
    i18n-editor = callPackage ./linguistics/i18n-editor { jre = pkgs.jdk11; };
    lsdreader = callPackage ./linguistics/lsdreader { };
    mikatools = callPackage ./linguistics/mikatools { };
    odict = callPackage ./linguistics/odict { };
    pytorchtext = callPackage ./linguistics/pytorchtext { };
    revtok = callPackage ./linguistics/revtok { };
    stardict-tools = callPackage ./linguistics/stardict-tools { };
    tatoebatools = callPackage ./linguistics/tatoebatools { };
    ttb = callPackage ./linguistics/ttb { };
    wikitextprocessor = callPackage ./linguistics/wikitextprocessor { };
    wiktextract = callPackage ./linguistics/wiktextract { };
    wiktfinnish = callPackage ./linguistics/wiktfinnish { };
    zdict = callPackage ./linguistics/zdict { };

    ### MISC

    aamath = callPackage ./misc/aamath { };
    acp = callPackage ./misc/acp { };
    ajv-cli = callPackage ./misc/ajv-cli { };
    apibackuper = callPackage ./misc/apibackuper { };
    arduinojson = callPackage ./misc/arduinojson { };
    ascii-dash = callPackage ./misc/ascii-dash { };
    bash-completor = callPackage ./misc/bash-completor { };
    brink = callPackage ./misc/brink { };
    btpd = callPackage ./misc/btpd { };
    bwh = callPackage ./misc/bwh { };
    capture2text = libsForQt5.callPackage ./misc/capture2text { };
    cfiles = callPackage ./misc/cfiles { };
    chasquid = callPackage ./misc/chasquid { };
    csv2html = callPackage ./misc/csv2html { };
    csvtools = callPackage ./misc/csvtools { };
    diagon = callPackage ./misc/diagon { };
    dns-filter = callPackage ./misc/dns-filter { };
    docker-reg-tool = callPackage ./misc/docker-reg-tool { };
    docx2csv = callPackage ./misc/docx2csv { };
    exercisediary = callPackage ./misc/exercisediary { };
    ffs = callPackage ./misc/ffs { };
    freeopcua = callPackage ./misc/freeopcua { };
    gaiagpsclient = callPackage ./misc/gaiagpsclient { };
    git-tui = callPackage ./misc/git-tui { };
    goto = callPackage ./misc/goto { };
    graphene = callPackage ./misc/graphene { };
    headscale-webui = callPackage ./misc/headscale-webui { };
    heapusage = callPackage ./misc/heapusage { };
    how-to-use-pvs-studio-free = callPackage ./misc/how-to-use-pvs-studio-free { };
    huami-token = callPackage ./misc/huami-token { };
    ionscale = callPackage ./misc/ionscale { };
    ish = callPackage ./misc/ish { };
    json-tui = callPackage ./misc/json-tui { };
    lazyscraper = callPackage ./misc/lazyscraper { };
    libmdbx = callPackage ./misc/libmdbx { };
    libnbcompat = callPackage ./misc/libnbcompat { };
    md2html = callPackage ./misc/md2html { };
    messenger-cli = callPackage ./misc/messenger-cli { };
    messenger-gtk = callPackage ./misc/messenger-gtk { };
    miband4 = callPackage ./misc/miband4 { };
    mitzasql = callPackage ./misc/mitzasql { };
    mjs = callPackage ./misc/mjs { };
    modbus-tools = callPackage ./misc/modbus-tools { };
    modbus_sim_cli = callPackage ./misc/modbus_sim_cli { python3Packages = pkgs.python310Packages; };
    morse-talk = callPackage ./misc/morse-talk { };
    msg-cli = callPackage ./misc/msg-cli { };
    musig = callPackage ./misc/musig { };
    mysql-to-sqlite3 = callPackage ./misc/mysql-to-sqlite3 { };
    nanodns = callPackage ./misc/nanodns { };
    nmtree = callPackage ./misc/nmtree { };
    objlab = callPackage ./misc/objlab { };
    ocelotgui = libsForQt5.callPackage ./misc/ocelotgui { };
    opcua = callPackage ./misc/opcua { };
    #opcua-stack = callPackage ./misc/opcua-stack {
    #  openssl = pkgs.openssl_1_1;
    #};
    playonmac = callPackage ./misc/playonmac { };
    plotjuggler = libsForQt5.callPackage ./misc/plotjuggler { };
    pnoise = callPackage ./misc/pnoise { };
    ptunnel = callPackage ./misc/ptunnel { };
    px = callPackage ./misc/px { };
    qdia = callPackage ./misc/qdia { };
    qoiview = callPackage ./misc/qoiview { };
    qstudio = callPackage ./misc/qstudio { };
    repolocli = callPackage ./misc/repolocli { };
    rhttp = callPackage ./misc/rhttp { };
    riffraff = callPackage ./misc/riffraff { };
    rodnik = callPackage ./misc/rodnik { };
    rst2txt = callPackage ./misc/rst2txt { };
    sdorfehs = callPackage ./misc/sdorfehs { };
    serverpp = callPackage ./misc/serverpp { };
    shellprof = callPackage ./misc/shellprof { };
    shifu = callPackage ./misc/shifu { };
    socketcand = callPackage ./misc/socketcand { };
    subprocess = callPackage ./misc/subprocess { };
    tcvt = callPackage ./misc/tcvt { };
    telegabber = callPackage ./misc/telegabber { };
    telegram-send = callPackage ./misc/telegram-send { };
    telnetpp = callPackage ./misc/telnetpp { };
    terminalpp = callPackage ./misc/terminalpp { };
    tewi = callPackage ./misc/tewi { };
    tg-spam = callPackage ./misc/tg-spam { };
    tiny-frpc = callPackage ./misc/tiny-frpc { };
    tinyflux = callPackage ./misc/tinyflux { };
    tlstunnel = callPackage ./misc/tlstunnel { };
    tsnsrv = callPackage ./misc/tsnsrv { };
    turbo = callPackage ./misc/turbo { };
    tvision = callPackage ./misc/tvision { };
    wik = callPackage ./misc/wik { };
    wirefire = callPackage ./misc/wirefire { };
    #worm = callPackage ./misc/worm { };
    wptools = callPackage ./misc/wptools { };
    xfractint = callPackage ./misc/xfractint { };
    xtr = callPackage ./misc/xtr { };
    youtimetrack = callPackage ./misc/youtimetrack { };
    zwave-js-ui = callPackage ./misc/zwave-js-ui { };

    ### MQTT

    akasa = callPackage ./mqtt/akasa { };
    amqtt = callPackage ./mqtt/amqtt { };
    comqtt = callPackage ./mqtt/comqtt { };
    go-mosquitto = callPackage ./mqtt/go-mosquitto { };
    go-mqtt-to-influxdb = callPackage ./mqtt/go-mqtt-to-influxdb { };
    hmq = callPackage ./mqtt/hmq { };
    ioxy = callPackage ./mqtt/ioxy { };
    janus-mqtt-proxy = callPackage ./mqtt/janus-mqtt-proxy { };
    libumqtt = callPackage ./mqtt/libumqtt { };
    mochi = callPackage ./mqtt/mochi { };
    mongoose = callPackage ./mqtt/mongoose { };
    mproxy = callPackage ./mqtt/mproxy { };
    mqcontrol = callPackage ./mqtt/mqcontrol { };
    mqtt-benchmark = callPackage ./mqtt/mqtt-benchmark { };
    mqtt-c = callPackage ./mqtt/mqtt-c { };
    mqtt-cli = callPackage ./mqtt/mqtt-cli { };
    mqtt-executor = callPackage ./mqtt/mqtt-executor { };
    mqtt-launcher = callPackage ./mqtt/mqtt-launcher { };
    mqtt-logger = callPackage ./mqtt/mqtt-logger { };
    mqtt-proxy = callPackage ./mqtt/mqtt-proxy { };
    mqtt-recorder = callPackage ./mqtt/mqtt-recorder { };
    mqtt-shell = callPackage ./mqtt/mqtt-shell { };
    mqtt-stats = callPackage ./mqtt/mqtt-stats { };
    mqtt-stresser = callPackage ./mqtt/mqtt-stresser { };
    mqtt-to-influxdb = callPackage ./mqtt/mqtt-to-influxdb { };
    mqtt-to-influxdb-forwarder = callPackage ./mqtt/mqtt-to-influxdb-forwarder { };
    mqttfs = callPackage ./mqtt/mqttfs { };
    mqttwarn = callPackage ./mqtt/mqttwarn { };
    mystique = callPackage ./mqtt/mystique { };
    nanosdk = callPackage ./mqtt/nanosdk { };
    pytest-mqtt = callPackage ./mqtt/pytest-mqtt { };
    rmqtt = callPackage ./mqtt/rmqtt { };
    rumqtt = callPackage ./mqtt/rumqtt { };
    volantmq = callPackage ./mqtt/volantmq { };

    ### NAKARTE

    elevation-server = callPackage ./nakarte/elevation-server { };
    map-tiler = callPackage ./nakarte/map-tiler { python3Packages = pkgs.python311Packages; };
    mapillary-render = callPackage ./nakarte/mapillary-render { };
    maprec = callPackage ./nakarte/maprec { python3Packages = pkgs.python311Packages; };
    #nakarte = callPackage ./nakarte/nakarte { };
    ozi-map = callPackage ./nakarte/ozi-map { python3Packages = pkgs.python311Packages; };
    pyimagequant = callPackage ./nakarte/pyimagequant { python3Packages = pkgs.python311Packages; };
    thinplatespline = callPackage ./nakarte/thinplatespline {
      python3Packages = pkgs.python311Packages;
    };
    tracks-storage-server = pkgs.python3Packages.callPackage ./nakarte/tracks-storage-server { };
    westra-passes = callPackage ./nakarte/westra-passes { };

    ### OSM

    abstreet = callPackage ./osm/abstreet { };
    arnis = callPackage ./osm/arnis { };
    cykhash = callPackage ./osm/cykhash { };
    gcgn-converter = callPackage ./osm/gcgn-converter { };
    level0 = callPackage ./osm/level0 { };
    libgeodesk = callPackage ./osm/libgeodesk { };
    map-machine = callPackage ./osm/map-machine { };
    map-stylizer = callPackage ./osm/map-stylizer { };
    maperitive = callPackage ./osm/maperitive { };
    maproulette-python-client = callPackage ./osm/maproulette-python-client { };
    memphis = callPackage ./osm/memphis { };
    osm-3s = callPackage ./osm/osm-3s { };
    osm-area-tools = callPackage ./osm/osm-area-tools { };
    osm-gis-export = callPackage ./osm/osm-gis-export { };
    osm-lump-ways = callPackage ./osm/osm-lump-ways { };
    osm-tags-transform = callPackage ./osm/osm-tags-transform { };
    osm2geojson = callPackage ./osm/osm2geojson { };
    osmcoastline = callPackage ./osm/osmcoastline { };
    osmdbt = callPackage ./osm/osmdbt { };
    osmium-surplus = callPackage ./osm/osmium-surplus { };
    osmosis = callPackage ./osm/osmosis { };
    osmptparser = callPackage ./osm/osmptparser { };
    osmviz = callPackage ./osm/osmviz { };
    osmwalkthrough = callPackage ./osm/osmwalkthrough { };
    overpassforge = callPackage ./osm/overpassforge { };
    phyghtmap = callPackage ./osm/phyghtmap { };
    planetiler = callPackage ./osm/planetiler { };
    polytiles = callPackage ./osm/polytiles { };
    prettymapp = callPackage ./osm/prettymapp { };
    py-osm-static-maps = callPackage ./osm/py-osm-static-maps { };
    pyrobuf = callPackage ./osm/pyrobuf { };
    pyrosm = callPackage ./osm/pyrosm { };
    sdlmap = callPackage ./osm/sdlmap { };
    smopy = callPackage ./osm/smopy { };
    smrender = callPackage ./osm/smrender { };
    srtm2osm = callPackage ./osm/srtm2osm { };
    taginfo-tools = callPackage ./osm/taginfo-tools { };
    tilelog = callPackage ./osm/tilelog { };
    vectiler = callPackage ./osm/vectiler { };

    ### RADIO

    acarsdec = callPackage ./radio/acarsdec { };
    adsb_deku = callPackage ./radio/adsb_deku { };
    ais-catcher = callPackage ./radio/ais-catcher { };
    aprsc = callPackage ./radio/aprsc { };
    dump1090_rs = callPackage ./radio/dump1090_rs { };
    dumphfdl = callPackage ./radio/dumphfdl { };
    fmreceiver = libsForQt5.callPackage ./radio/fmreceiver { };
    goestools = callPackage ./radio/goestools { };
    gqrx-scanner = callPackage ./radio/gqrx-scanner { };
    linrad = callPackage ./radio/linrad { };
    radiolib = callPackage ./radio/radiolib { };
    rtlsdr-airband = callPackage ./radio/rtlsdr-airband { };
    rtltcp = callPackage ./radio/rtltcp { };
    sdr-modem = callPackage ./radio/sdr-modem { };
    sdr-server = callPackage ./radio/sdr-server { };
    smallrx = callPackage ./radio/smallrx { };

    ### SUCKLESS

    amused = callPackage ./suckless/amused { };
    blind = callPackage ./suckless/blind { };
    chibicc = callPackage ./suckless/chibicc { };
    cproc = callPackage ./suckless/cproc { };
    dragon = callPackage ./suckless/dragon { };
    dtree = callPackage ./suckless/dtree { };
    edit = callPackage ./suckless/edit { };
    farbfeld-utils = callPackage ./suckless/farbfeld-utils { };
    ff-tools = callPackage ./suckless/ff-tools { };
    ffshot = callPackage ./suckless/ffshot { };
    hurl = callPackage ./suckless/hurl { };
    imscript = callPackage ./suckless/imscript { };
    imsg-compat = callPackage ./suckless/imsg-compat { };
    kilo = callPackage ./suckless/kilo { };
    lacc = callPackage ./suckless/lacc { };
    lbm = callPackage ./suckless/lbm { };
    lchat = callPackage ./suckless/lchat { };
    lel = callPackage ./suckless/lel { };
    libst = callPackage ./suckless/libst { };
    libutf = callPackage ./suckless/libutf { };
    mage = callPackage ./suckless/mage { };
    makel = callPackage ./suckless/makel { };
    nextvi = callPackage ./suckless/nextvi { };
    pista = callPackage ./suckless/pista { };
    poe = callPackage ./suckless/poe { };
    saait = callPackage ./suckless/saait { };
    sbase = callPackage ./suckless/sbase { };
    scc = callPackage ./suckless/scc { };
    scroll = callPackage ./suckless/scroll { };
    sdhcp = callPackage ./suckless/sdhcp { };
    se = callPackage ./suckless/se { };
    sled = callPackage ./suckless/sled { };
    ste = callPackage ./suckless/ste { };
    sthkd = callPackage ./suckless/sthkd { };
    svtm = callPackage ./suckless/svtm { };
    table = callPackage ./suckless/table { };
    webdump = callPackage ./suckless/webdump { };
  }
)
