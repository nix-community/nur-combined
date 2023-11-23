{ pkgs ? import <nixpkgs> { } }: rec {
  arkade = pkgs.libsForQt5.callPackage ./arkade { };
  blurble = pkgs.callPackage ./blurble { };
  brisk-menu = pkgs.callPackage ./brisk-menu { };
  bsdutils = pkgs.callPackage ./bsdutils { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./cargo-aoc { };
  casaos = pkgs.callPackage ./casaos { };
  eloquens = pkgs.libsForQt5.callPackage ./eloquens { };
  fastfetch = pkgs.callPackage ./fastfetch { inherit yyjson; };
  fielding = pkgs.libsForQt5.callPackage ./fielding { };
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme { };
  flyaway = pkgs.callPackage ./flyaway { };
  francis = pkgs.libsForQt5.callPackage ./francis { };
  game-of-life = pkgs.callPackage ./game-of-life { };
  gradebook = pkgs.callPackage ./gradebook { };
  gruvbox-plasma = pkgs.callPackage ./gruvbox-plasma { };
  gtatool = pkgs.callPackage ./gtatool { inherit libgta teem; };
  inko = pkgs.callPackage ./inko { };
  kommit = pkgs.libsForQt5.callPackage ./kommit { };
  kuroko = pkgs.callPackage ./kuroko { };
  libgta = pkgs.callPackage ./libgta { };
  libtgd = pkgs.callPackage ./libtgd { inherit libgta; };
  libxfce4windowing = pkgs.callPackage ./libxfce4windowing { };
  libxo = pkgs.callPackage ./libxo { };
  libzypp = pkgs.callPackage ./libzypp { libsolv = libsolv-libzypp; };
  licentia = pkgs.libsForQt5.callPackage ./licentia { };
  liquidshell = pkgs.libsForQt5.callPackage ./liquidshell { };
  magpie_v1 = pkgs.callPackage ./magpie_v1 { };
  marknote = pkgs.libsForQt5.callPackage ./marknote { };
  metronome = pkgs.callPackage ./metronome { };
  minesector = pkgs.callPackage ./minesector { };
  morewaita = pkgs.callPackage ./morewaita { };
  moss = pkgs.callPackage ./moss { };
  mucalc = pkgs.callPackage ./mucalc { };
  notae = pkgs.libsForQt5.callPackage ./notae { };
  opensurge = pkgs.callPackage ./opensurge { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./qv { inherit libtgd; };
  rollit = pkgs.callPackage ./rollit { };
  rollit3_2 = pkgs.callPackage ./rollit/3.2.0.nix { };
  share-preview = pkgs.callPackage ./share-preview { };
  share-preview0_3 = pkgs.callPackage ./share-preview/0.3.0.nix { };
  srb2p = pkgs.callPackage ./srb2p { };
  surgescript = pkgs.callPackage ./surgescript { };
  teem = pkgs.callPackage ./teem { };
  textsnatcher = pkgs.callPackage ./textsnatcher { };
  thunderbird-gnome-theme = pkgs.callPackage ./thunderbird-gnome-theme { };
  upkg = pkgs.callPackage ./upkg { };
  usysconf = pkgs.callPackage ./usysconf { };
  wisp = pkgs.callPackage ./wisp { };
  waycheck = pkgs.qt6.callPackage ./waycheck { };
  xdg-terminal-exec = pkgs.callPackage ./xdg-terminal-exec { };
  yyjson = pkgs.callPackage ./yyjson { };
  zypper = pkgs.callPackage ./zypper { inherit libzypp; };

  # Variants
  fastfetchFull = pkgs.lib.warn "fastfetchFull has been replaced by fastfetch, which will conditionally enable features based on platform support" fastfetch;

  fastfetchMinimal = (fastfetch.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-minimal";
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (with all features disabled)";
      mainProgram = "fastfetch";
    };
  })).override {
    enableLibpci = false;
    enableVulkan = false;
    enableWayland = false;
    enableXcb = false;
    enableXcbRandr = false;
    enableXrandr = false;
    enableX11 = false;
    enableGio = false;
    enableDconf = false;
    enableDbus = false;
    enableXfconf = false;
    enableSqlite3 = false;
    enableRpm = false;
    enableImagemagick7 = false;
    enableChafa = false;
    enableZlib = false;
    enableEgl = false;
    enableGlx = false;
    enableOsmesa = false;
    enableOpencl = false;
    enableLibnm = false;
    enableFreetype = false;
    enablePulse = false;
    enableDdcutil = false;
    enableDirectxHeaders = false;
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
