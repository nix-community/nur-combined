{ pkgs ? import <nixpkgs> { } }: rec {
  arkade = pkgs.libsForQt5.callPackage ./by-name/ar/arkade/package.nix { };
  atoms = pkgs.callPackage ./by-name/at/atoms/package.nix { inherit atoms-core; };
  atoms-core = pkgs.python3Packages.callPackage ./by-name/at/atoms-core/package.nix { };
  blurble = pkgs.callPackage ./by-name/bl/blurble/package.nix { };
  brisk-menu = pkgs.callPackage ./by-name/br/brisk-menu/package.nix { };
  bsdutils = pkgs.callPackage ./by-name/bs/bsdutils/package.nix { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./by-name/ca/cargo-aoc/package.nix { };
  casaos = pkgs.callPackage ./by-name/ca/casaos/package.nix { };
  chess-clock = pkgs.callPackage ./by-name/ch/chess-clock/package.nix { };
  chess-clock0_5 = pkgs.callPackage ./by-name/ch/chess-clock/0.5.0.nix { };
  codelite = pkgs.callPackage ./by-name/co/codelite/package.nix { };
  devtoolbox = pkgs.callPackage ./by-name/de/devtoolbox/package.nix { };
  eloquens = pkgs.libsForQt5.callPackage ./by-name/el/eloquens/package.nix { };
  fastfetch = pkgs.callPackage ./by-name/fa/fastfetch/package.nix { inherit yyjson; };
  fielding = pkgs.libsForQt5.callPackage ./by-name/fi/fielding/package.nix { };
  firefox-gnome-theme = pkgs.callPackage ./by-name/fi/firefox-gnome-theme/package.nix { };
  flyaway = pkgs.callPackage ./by-name/fl/flyaway/package.nix { };
  francis = pkgs.libsForQt5.callPackage ./by-name/fr/francis/package.nix { };
  game-of-life = pkgs.callPackage ./by-name/ga/game-of-life/package.nix { };
  gradebook = pkgs.callPackage ./by-name/gr/gradebook/package.nix { };
  gtatool = pkgs.callPackage ./by-name/gt/gtatool/package.nix { inherit libgta teem; };
  kommit = pkgs.libsForQt5.callPackage ./by-name/ko/kommit/package.nix { };
  kuroko = pkgs.callPackage ./by-name/ku/kuroko/package.nix { };
  licentia = pkgs.libsForQt5.callPackage ./by-name/li/licentia/package.nix { };
  libgta = pkgs.callPackage ./by-name/li/libgta/package.nix { };
  libtgd = pkgs.callPackage ./by-name/li/libtgd/package.nix { inherit libgta; };
  libxo = pkgs.callPackage ./by-name/li/libxo/package.nix { };
  libzypp = pkgs.callPackage ./by-name/li/libzypp/package.nix { libsolv = libsolv-libzypp; };
  liquidshell = pkgs.libsForQt5.callPackage ./by-name/li/liquidshell/package.nix { };
  marknote = pkgs.libsForQt5.callPackage ./by-name/ma/marknote/package.nix { };
  metronome = pkgs.callPackage ./by-name/me/metronome/package.nix { };
  minesector = pkgs.callPackage ./by-name/mi/minesector/package.nix { };
  morewaita = pkgs.callPackage ./by-name/mo/morewaita/package.nix { };
  moss = pkgs.callPackage ./by-name/mo/moss/package.nix { };
  mucalc = pkgs.callPackage ./by-name/mu/mucalc/package.nix { };
  notae = pkgs.libsForQt5.callPackage ./by-name/no/notae/package.nix { };
  opensurge = pkgs.callPackage ./by-name/op/opensurge/package.nix { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./by-name/qv/qv/package.nix { inherit libtgd; };
  rollit = pkgs.callPackage ./by-name/ro/rollit/package.nix { };
  rollit3_2 = pkgs.callPackage ./by-name/ro/rollit/3.2.0.nix { };
  share-preview = pkgs.callPackage ./by-name/sh/share-preview/package.nix { };
  share-preview0_3 = pkgs.callPackage ./by-name/sh/share-preview/0.3.0.nix { };
  srb2p = pkgs.callPackage ./by-name/sr/srb2p/package.nix { };
  surgescript = pkgs.callPackage ./by-name/su/surgescript/package.nix { };
  teem = pkgs.callPackage ./by-name/te/teem/package.nix { };
  telegraph = pkgs.callPackage ./by-name/te/telegraph/package.nix { };
  textsnatcher = pkgs.callPackage ./by-name/te/textsnatcher/package.nix { };
  thunderbird-gnome-theme = pkgs.callPackage ./by-name/th/thunderbird-gnome-theme/package.nix { };
  upkg = pkgs.callPackage ./by-name/up/upkg/package.nix { };
  usysconf = pkgs.callPackage ./by-name/us/usysconf/package.nix { };
  waycheck = pkgs.qt6.callPackage ./by-name/wa/waycheck/package.nix { };
  xdg-terminal-exec = pkgs.callPackage ./by-name/xd/xdg-terminal-exec/package.nix { };
  yyjson = pkgs.yyjson or (pkgs.callPackage ./by-name/yy/yyjson/package.nix { });
  zypper = pkgs.callPackage ./by-name/zy/zypper/package.nix { inherit libzypp; };

  fastfetchFull = (fastfetch.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-full";
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (with all features enabled)";
    };
  })).override {
    enableChafa = true;
    enableDbus = true;
    enableDconf = true;
    enableDdcutil = true;
    enableEgl = true;
    enableFreetype = true;
    enableGio = true;
    enableGlx = true;
    enableImagemagick = true;
    enableLibnm = true;
    enableLibpci = true;
    enableMesa = true;
    enableOpencl = true;
    enablePulse = true;
    enableRpm = true;
    enableSqlite3 = true;
    enableVulkan = true;
    enableWayland = true;
    enableX11 = true;
    enableXcb = true;
    enableXfconf = true;
    enableXrandr = true;
    enableZlib = true;
  };

  gtatoolFull = (gtatool.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-full";
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (with all features enabled)";
    };
  })).override {
    # Broken
    withBashCompletion = false;
    withDcmtk = true;
    # Needs patching
    withExr = false;
    # Needs patching
    withFfmpeg = false;
    withGdal = true;
    withJpeg = true;
    # ImageMagick 6 is marked as insecure
    withMagick = false;
    withMatio = true;
    withMuparser = true;
    withNetcdf = true;
    withNetpbm = true;
    withPcl = true;
    # Requires ImageMagick 6
    withPfs = false;
    withPng = true;
    # Needs patching
    withQt = false;
    withSndfile = true;
    withTeem = true;
  };

  libtgdFull = (libtgd.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-full";
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (with all features enabled)";
    };
  })).override {
    withCfitsio = true;
    withDmctk = true;
    # Broken
    withExiv2 = false;
    withFfmpeg = true;
    withGdal = true;
    withGta = true;
    withHdf5 = true;
    withJpeg = true;
    # ImageMagick 6 is marked as insecure
    withMagick = false;
    withMatio = true;
    withMuparser = true;
    withOpenexr = true;
    # Requires ImageMagick 6
    withPfs = false;
    withPng = true;
    withPoppler = true;
    withTiff = true;
  };

  teemFull = (teem.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-full";
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (with all features enabled)";
    };
  })).override {
    withLevmar = true;
    withFftw3 = true;
  };

  teemExperimental = (teem.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-experimental";
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (with experimental libraries and applications enabled)";
    };
  })).override {
    withExperimentalLibs = true;
    withExperimentalApps = true;
  };

  teemExperimentalFull = (teem.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-experimental-full";
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (with experimental libraries and applications, and all features enabled)";
    };
  })).override {
    withLevmar = true;
    withFftw3 = true;
    withExperimentalLibs = true;
    withExperimentalApps = true;
  };

  libsolv-libzypp = pkgs.libsolv.overrideAttrs (oldAttrs: {
    pname = "libsolv-libzypp";
    cmakeFlags = oldAttrs.cmakeFlags ++ [
      "-DENABLE_HELIXREPO=true"
    ];
    meta = oldAttrs.meta // {
      description = oldAttrs.meta.description + " (for LibZYpp)";
    };
  });
}
