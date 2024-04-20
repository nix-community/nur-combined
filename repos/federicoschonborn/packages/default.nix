{
  pkgs ? import <nixpkgs> { },
}:

pkgs.lib.makeScope pkgs.newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    biplanes-revival = callPackage ./biplanes-revival { };
    bsdutils = callPackage ./bsdutils { };
    cargo-aoc = callPackage ./cargo-aoc { };
    fastfetch = callPackage ./fastfetch { };
    firefox-gnome-theme = callPackage ./firefox-gnome-theme { };
    flyaway = callPackage ./flyaway { };
    gtatool = callPackage ./gtatool { };
    inko = callPackage ./inko { };
    kuroko = callPackage ./kuroko { };
    libgta = callPackage ./libgta { };
    libtgd = callPackage ./libtgd { };
    libxo = callPackage ./libxo { };
    magpie-wayland = callPackage ./magpie-wayland { };
    mii-emu = callPackage ./mii-emu { };
    minesector = callPackage ./minesector { };
    mucalc = callPackage ./mucalc { };
    opensurge = callPackage ./opensurge { };
    qv = callPackage ./qv { };
    raze = callPackage ./raze { };
    srb2p = callPackage ./srb2p { };
    supermodel = callPackage ./supermodel { };
    surgescript = callPackage ./surgescript { };
    teem = callPackage ./teem { };
    thunderbird-gnome-theme = callPackage ./thunderbird-gnome-theme { };
    unnamed-sdvx-clone = callPackage ./unnamed-sdvx-clone { };
    wisp = callPackage ./wisp { };

    # Backports
    wlroots_0_17 = pkgs.wlroots.overrideAttrs (prevAttrs: {
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
    });

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

    razeFull =
      (self.raze.overrideAttrs (prevAttrs: {
        pname = "${prevAttrs.pname}-full";
        meta = prevAttrs.meta // {
          description = "${prevAttrs.meta.description} (with all features enabled)";
        };
      })).override
        { withGtk3 = true; };

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
  }
)
