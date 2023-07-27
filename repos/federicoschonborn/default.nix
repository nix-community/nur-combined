# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{ pkgs ? import <nixpkgs> { } }: rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

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
  atoms = pkgs.callPackage ./packages/atoms.nix { inherit atoms-core; };
  atoms-core = pkgs.python3Packages.callPackage ./packages/atoms-core.nix { };
  blurble = pkgs.callPackage ./packages/blurble.nix { };
  boulder = pkgs.callPackage ./packages/boulder.nix { inherit libmoss; };
  brisk-menu = pkgs.callPackage ./packages/brisk-menu.nix { };
  bsdutils = pkgs.callPackage ./packages/bsdutils.nix { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./packages/cargo-aoc.nix { };
  casaos = pkgs.callPackage ./packages/casaos.nix { };
  chess-clock = pkgs.callPackage ./packages/chess-clock.nix { };
  devtoolbox = pkgs.callPackage ./packages/devtoolbox.nix { };
  fastfetch = pkgs.callPackage ./packages/fastfetch.nix { };
  firefox-gnome-theme = pkgs.callPackage ./packages/firefox-gnome-theme.nix { };
  flyaway = pkgs.callPackage ./packages/flyaway.nix { wlroots = wlroots_0_16; };
  gradebook = pkgs.callPackage ./packages/gradebook.nix { };
  gtatool = pkgs.callPackage ./packages/gtatool { inherit libgta teem; };
  kommit = pkgs.libsForQt5.callPackage ./packages/kommit.nix { };
  libgta = pkgs.callPackage ./packages/libgta.nix { };
  libtgd = pkgs.callPackage ./packages/libtgd.nix { inherit libgta; };
  libxo = pkgs.callPackage ./packages/libxo { };
  liquidshell = pkgs.libsForQt5.callPackage ./packages/liquidshell.nix { };
  metronome = pkgs.callPackage ./packages/metronome.nix { };
  morewaita = pkgs.callPackage ./packages/morewaita.nix { };
  moss = pkgs.callPackage ./packages/moss.nix { inherit libmoss; };
  moss-container = pkgs.callPackage ./packages/moss-container.nix { inherit libmoss; };
  mucalc = pkgs.callPackage ./packages/mucalc.nix { };
  opensurge = pkgs.callPackage ./packages/opensurge.nix { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./packages/qv.nix { inherit libtgd; };
  share-preview = pkgs.callPackage ./packages/share-preview.nix { };
  srb2p = pkgs.callPackage ./packages/srb2p { };
  surgescript = pkgs.callPackage ./packages/surgescript.nix { };
  teem = pkgs.callPackage ./packages/teem.nix { };
  telegraph = pkgs.callPackage ./packages/telegraph.nix { };
  textsnatcher = pkgs.callPackage ./packages/textsnatcher.nix { };
  tuba = pkgs.callPackage ./packages/tuba.nix { };

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
}
