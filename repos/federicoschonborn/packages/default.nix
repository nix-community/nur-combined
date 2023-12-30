{ pkgs ? import <nixpkgs> { } }: rec {
  bsdutils = pkgs.callPackage ./bsdutils { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./cargo-aoc { };
  fastfetch = pkgs.callPackage ./fastfetch { };
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme { };
  flyaway = pkgs.callPackage ./flyaway { };
  gtatool = pkgs.callPackage ./gtatool { inherit libgta teem; };
  inko = pkgs.callPackage ./inko { };
  irust = pkgs.callPackage ./irust { };
  kuroko = pkgs.callPackage ./kuroko { };
  libgta = pkgs.callPackage ./libgta { };
  libtgd = pkgs.callPackage ./libtgd { inherit libgta; };
  libxo = pkgs.callPackage ./libxo { };
  libzypp = pkgs.callPackage ./libzypp { };
  magpie1 = pkgs.callPackage ./magpie1 { inherit wlroots_0_17; };
  minesector = pkgs.callPackage ./minesector { };
  morewaita = pkgs.callPackage ./morewaita { };
  moss = pkgs.callPackage ./moss { };
  mucalc = pkgs.callPackage ./mucalc { };
  opensurge = pkgs.callPackage ./opensurge { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./qv { inherit libtgd; };
  srb2p = pkgs.callPackage ./srb2p { };
  surgescript = pkgs.callPackage ./surgescript { };
  teem = pkgs.callPackage ./teem { };
  thunderbird-gnome-theme = pkgs.callPackage ./thunderbird-gnome-theme { };
  usysconf = pkgs.callPackage ./usysconf { };
  wisp = pkgs.callPackage ./wisp { };
  waycheck = pkgs.qt6.callPackage ./waycheck { };
  xdg-terminal-exec = pkgs.callPackage ./xdg-terminal-exec { };
  zypper = pkgs.callPackage ./zypper { inherit libzypp; };

  wlroots_0_17 = if pkgs?wlroots_0_17 then pkgs.wlroots_0_17 else
  pkgs.wlroots_0_16.overrideAttrs (prevAttrs: {
    version = "0.17.1";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "wlroots";
      repo = "wlroots";
      rev = "3f2aced8c6fd00b0b71da24c790850af2004052b";
      hash = "sha256-Z0gWM7AQqJOSr2maUtjdgk/MF6pyeyFMMTaivgt+RMI=";
    };
    buildInputs = (prevAttrs.buildInputs or [ ]) ++ [
      pkgs.hwdata
      pkgs.libdisplay-info
    ];
  });

  # Variants
  fastfetchMinimal = (fastfetch.overrideAttrs (prevAttrs: {
    pname = "${prevAttrs.pname}-minimal";
    meta = prevAttrs.meta // {
      description = "${prevAttrs.meta.description} (with all features disabled)";
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

  gtatoolFull = (gtatool.overrideAttrs (prevAttrs: {
    pname = "${prevAttrs.pname}-full";
    meta = prevAttrs.meta // {
      description = "${prevAttrs.meta.description} (with all features enabled)";
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

  libtgdFull = (libtgd.overrideAttrs (prevAttrs: {
    pname = "${prevAttrs.pname}-full";
    meta = prevAttrs.meta // {
      description = "${prevAttrs.meta.description} (with all features enabled)";
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

  teemFull = (teem.overrideAttrs (prevAttrs: {
    pname = "${prevAttrs.pname}-full";
    meta = prevAttrs.meta // {
      description = "${prevAttrs.meta.description} (with all features enabled)";
    };
  })).override {
    withLevmar = true;
    withFftw3 = true;
  };

  teemExperimental = (teem.overrideAttrs (prevAttrs: {
    pname = "${prevAttrs.pname}-experimental";
    meta = prevAttrs.meta // {
      description = "${prevAttrs.meta.description} (with experimental libraries and applications enabled)";
    };
  })).override {
    withExperimentalLibs = true;
    withExperimentalApps = true;
  };

  teemExperimentalFull = (teem.overrideAttrs (prevAttrs: {
    pname = "${prevAttrs.pname}-experimental-full";
    meta = prevAttrs.meta // {
      description = "${prevAttrs.meta.description} (with experimental libraries and applications, and all features enabled)";
    };
  })).override {
    withLevmar = true;
    withFftw3 = true;
    withExperimentalLibs = true;
    withExperimentalApps = true;
  };
}
