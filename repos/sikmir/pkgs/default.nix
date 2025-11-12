{ pkgs }:
let
  inherit (pkgs)
    lib
    newScope
    libsForQt5
    darwin
    ;
in
lib.makeScope newScope (
  self:
  with self;
  (lib.foldlAttrs
    (
      acc: _: attrs:
      acc // attrs
    )
    { }
    (
      lib.packagesFromDirectoryRecursive {
        inherit callPackage;
        directory = ./by-name;
      }
    )
  )
  // {
    # VSCODE EXTENSIONS

    vscode-extensions = lib.recurseIntoAttrs (callPackage ./vscode-extensions.nix { });

    ### BUILD SUPPORT

    fetchfromgh = callPackage ./build-support/fetchfromgh { };
    fetchgdrive = callPackage ./build-support/fetchgdrive { };
    fetchwebarchive = callPackage ./build-support/fetchwebarchive { };
    fetchymaps = callPackage ./build-support/fetchymaps { };

    ### DATA

    dadako = callPackage ./data/dicts/dadako { };
    freedict = callPackage ./data/dicts/freedict { };
    huzheng = callPackage ./data/dicts/huzheng { };

    dem = callPackage ./data/maps/dem { };
    freizeitkarte-osm = callPackage ./data/maps/freizeitkarte-osm { };
    vlasenko-maps = callPackage ./data/maps/vlasenko-maps { };
    meridian = callPackage ./data/maps/meridian { };
    uralla = callPackage ./data/maps/uralla { };

    poi = callPackage ./data/misc/poi { };

    osm-extracts = callPackage ./data/osm/osm-extracts { };
    overpassdb = callPackage ./data/osm/overpassdb { };
    routinodb = callPackage ./data/osm/routinodb { };

    ### DEVELOPMENT / PERL MODULES

    perlPackages =
      (callPackage ./perl-packages.nix { }) // pkgs.perlPackages // { recurseForDerivations = false; };

    ### DEVELOPMENT / PYTHON MODULES

    bounded-pool-executor = callPackage ./development/python-modules/bounded-pool-executor { };
    click_6_7 = callPackage ./development/python-modules/click { };
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

    embox-aarch64 = callPackage ./embedded/embox { arch = "aarch64"; };
    embox-arm = callPackage ./embedded/embox { arch = "arm"; };
    embox-ppc = callPackage ./embedded/embox { arch = "ppc"; };
    embox-riscv64 = callPackage ./embedded/embox { arch = "riscv64"; };
    embox-x86 = callPackage ./embedded/embox { stdenv = pkgs.gccMultiStdenv; };

    ### GEOSPATIAL

    #tdh = callPackage ./geospatial/tdh { };

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

    ### NAKARTE

    #nakarte = callPackage ./nakarte/nakarte { };
    tracks-storage-server = pkgs.python3Packages.callPackage ./nakarte/tracks-storage-server { };
  }
)
