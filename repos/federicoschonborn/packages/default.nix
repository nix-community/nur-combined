{
  pkgs ? import <nixpkgs> { },
}:
let
  self = {
    bsdutils = pkgs.callPackage ./bsdutils { inherit (self) libxo; };
    cargo-aoc = pkgs.callPackage ./cargo-aoc { };
    fastfetch = pkgs.callPackage ./fastfetch { };
    firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme { };
    flyaway = pkgs.callPackage ./flyaway { };
    gtatool = pkgs.callPackage ./gtatool { inherit (self) libgta teem; };
    inko = pkgs.callPackage ./inko { };
    kuroko = pkgs.callPackage ./kuroko { };
    libgta = pkgs.callPackage ./libgta { };
    libtgd = pkgs.callPackage ./libtgd { inherit (self) libgta; };
    libxo = pkgs.callPackage ./libxo { };
    magpie-wayland = pkgs.callPackage ./magpie-wayland { inherit (self) wlroots_0_17; };
    minesector = pkgs.callPackage ./minesector { };
    mucalc = pkgs.callPackage ./mucalc { };
    opensurge = pkgs.callPackage ./opensurge { inherit (self) surgescript; };
    qv = pkgs.qt6.callPackage ./qv { inherit (self) libtgd; };
    srb2p = pkgs.callPackage ./srb2p { };
    surgescript = pkgs.callPackage ./surgescript { };
    teem = pkgs.callPackage ./teem { };
    thunderbird-gnome-theme = pkgs.callPackage ./thunderbird-gnome-theme { };
    wisp = pkgs.callPackage ./wisp { };

    # Backports
    wlroots_0_17 =
      pkgs.wlroots_0_17 or (pkgs.wlroots.overrideAttrs (prevAttrs: {
        version = "0.17.2";
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "wlroots";
          repo = "wlroots";
          rev = "6dce6ae2ed92544b9758b194618e21f4c97f1d6b";
          hash = "sha256-Of9qykyVnBURc5A2pvCMm7sLbnuuG7OPWLxodQLN2Xg=";
        };
        buildInputs = (prevAttrs.buildInputs or [ ]) ++ [
          pkgs.hwdata
          pkgs.libdisplay-info
        ];
      }));

    # Variants
    fastfetchMinimal =
      (self.fastfetch.overrideAttrs (prevAttrs: {
        pname = "${prevAttrs.pname}-minimal";
        meta = prevAttrs.meta // {
          description = "${prevAttrs.meta.description} (with all features disabled)";
          mainProgram = "fastfetch";
        };
      })).override
        {
          enableVulkan = false;
          enableWayland = false;
          enableXcb = false;
          enableXcbRandr = false;
          enableXrandr = false;
          enableX11 = false;
          enableDrm = false;
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
          enableProprietaryGpuDriverApi = false;
        };

    gtatoolFull =
      (self.gtatool.overrideAttrs (prevAttrs: {
        pname = "${prevAttrs.pname}-full";
        meta = prevAttrs.meta // {
          description = "${prevAttrs.meta.description} (with all features enabled)";
        };
      })).override
        {
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

    libtgdFull =
      (self.libtgd.overrideAttrs (prevAttrs: {
        pname = "${prevAttrs.pname}-full";
        meta = prevAttrs.meta // {
          description = "${prevAttrs.meta.description} (with all features enabled)";
        };
      })).override
        {
          withTool = true;
          withDocs = true;
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

    teemFull =
      (self.teem.overrideAttrs (prevAttrs: {
        pname = "${prevAttrs.pname}-full";
        meta = prevAttrs.meta // {
          description = "${prevAttrs.meta.description} (with all features enabled)";
        };
      })).override
        {
          withBzip2 = true;
          withPthread = true;
          withFftw3 = true;
          withLevmar = true;
          withPng = true;
          withZlib = true;
        };

    teemExperimental =
      (self.teem.overrideAttrs (prevAttrs: {
        pname = "${prevAttrs.pname}-experimental";
        meta = prevAttrs.meta // {
          description = "${prevAttrs.meta.description} (with experimental libraries and applications enabled)";
        };
      })).override
        {
          withExperimentalApps = true;
          withExperimentalLibs = true;
        };

    teemExperimentalFull =
      (self.teem.overrideAttrs (prevAttrs: {
        pname = "${prevAttrs.pname}-experimental-full";
        meta = prevAttrs.meta // {
          description = "${prevAttrs.meta.description} (with experimental libraries and applications, and all features enabled)";
        };
      })).override
        {
          withExperimentalApps = true;
          withExperimentalLibs = true;
          withBzip2 = true;
          withPthread = true;
          withFftw3 = true;
          withLevmar = true;
          withPng = true;
          withZlib = true;
        };
  };
in
self
