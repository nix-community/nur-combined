{ pkgs ? import <nixpkgs> { } }: rec {
  arkade = pkgs.libsForQt5.callPackage ./arkade { };
  atoms = pkgs.callPackage ./atoms { inherit atoms-core; };
  atoms-core = pkgs.python3Packages.callPackage ./atoms-core { };
  blurble = pkgs.callPackage ./blurble { };
  boulder = pkgs.callPackage ./boulder { inherit libmoss; };
  brisk-menu = pkgs.callPackage ./brisk-menu { };
  bsdutils = pkgs.callPackage ./bsdutils { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./cargo-aoc { };
  casaos = pkgs.callPackage ./casaos { };
  chess-clock = pkgs.callPackage ./chess-clock { };
  codelite = pkgs.callPackage ./codelite { };
  devtoolbox = pkgs.callPackage ./devtoolbox { };
  eloquens = pkgs.libsForQt5.callPackage ./eloquens { };
  fastfetch = pkgs.callPackage ./fastfetch { inherit yyjson; };
  fielding = pkgs.libsForQt5.callPackage ./fielding { };
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme { };
  flyaway = pkgs.callPackage ./flyaway { wlroots = wlroots_0_16; };
  francis = pkgs.libsForQt5.callPackage ./francis { kirigami-addons = kirigami-addons_0_10; };
  game-of-life = pkgs.callPackage ./game-of-life { };
  gradebook = pkgs.callPackage ./gradebook { };
  gtatool = pkgs.callPackage ./gtatool { inherit libgta teem; };
  kommit = pkgs.libsForQt5.callPackage ./kommit { };
  kuroko = pkgs.callPackage ./kuroko { };
  licentia = pkgs.libsForQt5.callPackage ./licentia { kirigami-addons = kirigami-addons_0_10; };
  libgta = pkgs.callPackage ./libgta { };
  libtgd = pkgs.callPackage ./libtgd { inherit libgta; };
  libxo = pkgs.callPackage ./libxo { };
  libzypp = pkgs.callPackage ./libzypp { libsolv = libsolv-libzypp; };
  liquidshell = pkgs.libsForQt5.callPackage ./liquidshell { };
  marknote = pkgs.libsForQt5.callPackage ./marknote { };
  metronome = pkgs.callPackage ./metronome { };
  minesector = pkgs.callPackage ./minesector { };
  morewaita = pkgs.callPackage ./morewaita { };
  moss = pkgs.callPackage ./moss { inherit libmoss; };
  moss-container = pkgs.callPackage ./moss-container { inherit libmoss; };
  mucalc = pkgs.callPackage ./mucalc { };
  notae = pkgs.libsForQt5.callPackage ./notae { };
  opensurge = pkgs.callPackage ./opensurge { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./qv { inherit libtgd; };
  rollit = pkgs.callPackage ./rollit { };
  rpcsx = pkgs.callPackage ./rpcsx { };
  share-preview = pkgs.callPackage ./share-preview { };
  #sonic-2013 = pkgs.callPackage ./sonic-2013 { };
  #sonic-cd = pkgs.callPackage ./sonic-cd { };
  srb2p = pkgs.callPackage ./srb2p { };
  surgescript = pkgs.callPackage ./surgescript { };
  teem = pkgs.callPackage ./teem { };
  telegraph = pkgs.callPackage ./telegraph { };
  textsnatcher = pkgs.callPackage ./textsnatcher { };
  thunderbird-gnome-theme = pkgs.callPackage ./thunderbird-gnome-theme { };
  upkg = pkgs.callPackage ./upkg { };
  vita3k = pkgs.callPackage ./vita3k { };
  xdg-terminal-exec = pkgs.callPackage ./xdg-terminal-exec { };
  xenia = pkgs.callPackage ./xenia { };
  yyjson = pkgs.yyjson or (pkgs.callPackage ./yyjson { });
  zypper = pkgs.callPackage ./zypper { inherit libzypp; };

  apx_v2 = pkgs.apx.overrideAttrs (oldAttrs: {
    version = "2.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "Vanilla-OS";
      repo = "apx";
      rev = "d51bcf0680498a99a0835222838f1383ba8510ef";
      hash = "sha256-lGsl6Tbo5AUpNeWbbfMUS8H+Gmt66tqkyxclXiC2I0Y=";
    };
    # Same as Nixpkgs' but without the manpage copying.
    postInstall = ''
      mkdir -p $out/etc/apx

      cat > "$out/etc/apx/config.json" <<EOF
        {
          "containername": "apx_managed",
          "image": "docker.io/library/ubuntu",
          "pkgmanager": "apt",
          "distroboxpath": "${pkgs.distrobox}/bin/distrobox"
        }
      EOF

      wrapProgram $out/bin/apx --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.docker pkgs.distrobox ]}
    '';
    passthru = {
      updateScript = pkgs.unstableGitUpdater { };
    };
    meta = oldAttrs.meta // {
      platforms = pkgs.lib.platforms.linux;
    };
  });

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
      # Only God knows why this fails during installPhase but the non-full
      # package doesn't.
      broken = true;
    };
  })).override {
    withBashCompletion = true;
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

  kate-standalone = pkgs.kate.overrideAttrs (oldAttrs: {
    pname = "kate-standalone";
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      "-DBUILD_kwrite=false"
    ];
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (without KWrite)";
    };
  });

  kwrite-standalone = pkgs.kate.overrideAttrs (oldAttrs: {
    pname = "kwrite-standalone";
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      "-DBUILD_addons=false"
      "-DBUILD_kate=false"
    ];
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (without Kate)";
    };
  });

  libsolv-libzypp = pkgs.libsolv.overrideAttrs (oldAttrs: {
    pname = "libsolv-libzypp";
    cmakeFlags = oldAttrs.cmakeFlags ++ [
      "-DENABLE_HELIXREPO=true"
    ];
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (for libzypp)";
    };
  });

  libtgdFull = (libtgd.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-full";
    meta = oldAttrs.meta // {
      description = "${oldAttrs.meta.description} (with all features enabled)";
    };
  })).override {
    withCfitsio = true;
    withDmctk = true;
    withExiv2 = true;
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

  libmoss = pkgs.fetchFromGitHub {
    name = "libmoss";
    owner = "FedericoSchonborn";
    repo = "libmoss";
    rev = "fc143087d0d7b124a3dfd7c5e635223d9b12064a";
    hash = "sha256-oOm2luvqIr41ehDbfQUEGrJ4LdrngIo0RJ1OqGHD3d4=";
  };

  wlroots_0_16 = pkgs.wlroots.overrideAttrs (prev: rec {
    version = "0.16.2";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "wlroots";
      repo = "wlroots";
      rev = version;
      hash = "sha256-JeDDYinio14BOl6CbzAPnJDOnrk4vgGNMN++rcy2ItQ=";
    };
    buildInputs = prev.buildInputs ++ [ pkgs.hwdata ];
  });

  kirigami-addons_0_10 = pkgs.libsForQt5.kirigami-addons.overrideAttrs (oldAttrs: rec {
    version = "0.10.0";
    src = pkgs.fetchFromGitLab {
      domain = "invent.kde.org";
      owner = "libraries";
      repo = "kirigami-addons";
      rev = "v${version}";
      hash = "sha256-wwc0PCY8vNCmmwfIYYQhQea9AYkHakvTaERtazz8npQ=";
    };
    meta = oldAttrs.meta // (with pkgs.lib; {
      platforms = platforms.linux;
    });
  });
}
