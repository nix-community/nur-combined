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

    tracks-storage-server = pkgs.python3Packages.callPackage ./nakarte/tracks-storage-server { };
  }
)
