{ pkgs ? import <nixpkgs> { } }: rec {
  arkade = pkgs.libsForQt5.callPackage ./arkade.nix { };
  atoms = pkgs.callPackage ./atoms.nix { inherit atoms-core; };
  atoms-core = pkgs.python3Packages.callPackage ./atoms-core.nix { };
  blurble = pkgs.callPackage ./blurble.nix { };
  boulder = pkgs.callPackage ./boulder.nix { inherit libmoss; };
  brisk-menu = pkgs.callPackage ./brisk-menu.nix { };
  bsdutils = pkgs.callPackage ./bsdutils.nix { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./cargo-aoc.nix { };
  casaos = pkgs.callPackage ./casaos.nix { };
  chess-clock = pkgs.callPackage ./chess-clock.nix { };
  devtoolbox = pkgs.callPackage ./devtoolbox.nix { };
  eloquens = pkgs.libsForQt5.callPackage ./eloquens.nix { };
  fastfetch = pkgs.callPackage ./fastfetch.nix { };
  fielding = pkgs.libsForQt5.callPackage ./fielding.nix { };
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme.nix { };
  flyaway = pkgs.callPackage ./flyaway.nix { wlroots = wlroots_0_16; };
  francis = pkgs.libsForQt5.callPackage ./francis.nix { kirigami-addons = kirigami-addons_0_10; };
  gradebook = pkgs.callPackage ./gradebook.nix { };
  gtatool = pkgs.callPackage ./gtatool { inherit libgta teem; };
  kommit = pkgs.libsForQt5.callPackage ./kommit.nix { };
  licentia = pkgs.libsForQt5.callPackage ./licentia.nix { kirigami-addons = kirigami-addons_0_10; };
  libgta = pkgs.callPackage ./libgta.nix { };
  libtgd = pkgs.callPackage ./libtgd.nix { inherit libgta; };
  libxo = pkgs.callPackage ./libxo { };
  libzypp = pkgs.callPackage ./libzypp.nix { libsolv = libsolv-libzypp; };
  liquidshell = pkgs.libsForQt5.callPackage ./liquidshell.nix { };
  marknote = pkgs.libsForQt5.callPackage ./marknote.nix { };
  metronome = pkgs.callPackage ./metronome.nix { };
  morewaita = pkgs.callPackage ./morewaita.nix { };
  moss = pkgs.callPackage ./moss.nix { inherit libmoss; };
  moss-container = pkgs.callPackage ./moss-container.nix { inherit libmoss; };
  mucalc = pkgs.callPackage ./mucalc.nix { };
  notae = pkgs.libsForQt5.callPackage ./notae.nix { };
  opensurge = pkgs.callPackage ./opensurge.nix { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./qv.nix { inherit libtgd; };
  share-preview = pkgs.callPackage ./share-preview.nix { };
  srb2p = pkgs.callPackage ./srb2p { };
  surgescript = pkgs.callPackage ./surgescript.nix { };
  teem = pkgs.callPackage ./teem.nix { };
  telegraph = pkgs.callPackage ./telegraph.nix { };
  textsnatcher = pkgs.callPackage ./textsnatcher.nix { };
  thunderbird-gnome-theme = pkgs.callPackage ./thunderbird-gnome-theme.nix { };
  tuba = pkgs.callPackage ./tuba.nix { };
  upkg = pkgs.callPackage ./upkg.nix { };
  xdg-terminal-exec = pkgs.callPackage ./xdg-terminal-exec.nix { };
  zypper = pkgs.callPackage ./zypper.nix { inherit libzypp; };

  apx_v2 = pkgs.apx.overrideAttrs (oldAttrs: {
    version = "unstable-2023-07-17";
    src = pkgs.fetchFromGitHub {
      owner = "Vanilla-OS";
      repo = "apx";
      rev = "dd36d35c240a1ecb33f5583d850cba29e9c7470f";
      hash = "sha256-tVKmgDYAONNC0f3PRhbtTpfIwQw7/RulANPVWaXz53A=";
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
