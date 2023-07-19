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

  atoms = pkgs.callPackage ./packages/atoms { inherit atoms-core; };
  atoms-core = pkgs.python3Packages.callPackage ./packages/atoms-core { };
  blurble = pkgs.callPackage ./packages/blurble { };
  boulder = pkgs.callPackage ./packages/boulder { inherit libmossSrc; };
  brisk-menu = pkgs.callPackage ./packages/brisk-menu { };
  bsdutils = pkgs.callPackage ./packages/bsdutils { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./packages/cargo-aoc { };
  chess-clock = pkgs.callPackage ./packages/chess-clock { };
  devtoolbox = pkgs.callPackage ./packages/devtoolbox { };
  fastfetch = pkgs.callPackage ./packages/fastfetch { };
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
    enableLibcjson = true;
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
  firefox-gnome-theme = pkgs.callPackage ./packages/firefox-gnome-theme { };
  flyaway = pkgs.callPackage ./packages/flyaway { wlroots = wlroots_0_16; };
  gradebook = pkgs.callPackage ./packages/gradebook { };
  kommit = pkgs.libsForQt5.callPackage ./packages/kommit { };
  libgta = pkgs.callPackage ./packages/libgta { };
  libtgd = pkgs.callPackage ./packages/libtgd { inherit libgta; };
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
    # ImageMagick 6 is marked as insecure
    withImagemagick = false;
    withLibjpeg = true;
    withLibpng = true;
    withLibtiff = true;
    withMatio = true;
    withMuparser = true;
    withOpenexr = true;
    # Requires ImageMagick 6
    withPfstools = false;
    withPoppler = true;
  };
  libxo = pkgs.callPackage ./packages/libxo { };
  liquidshell = pkgs.libsForQt5.callPackage ./packages/liquidshell { };
  metronome = pkgs.callPackage ./packages/metronome { };
  morewaita = pkgs.callPackage ./packages/morewaita { };
  moss = pkgs.callPackage ./packages/moss { inherit libmossSrc; };
  moss-container = pkgs.callPackage ./packages/moss-container { inherit libmossSrc; };
  mucalc = pkgs.callPackage ./packages/mucalc { };
  opensurge = pkgs.callPackage ./packages/opensurge { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./packages/qv { inherit libtgd; };
  share-preview = pkgs.callPackage ./packages/share-preview { };
  srb2p = pkgs.callPackage ./packages/srb2p { };
  surgescript = pkgs.callPackage ./packages/surgescript { };
  telegraph = pkgs.callPackage ./packages/telegraph { };
  textsnatcher = pkgs.callPackage ./packages/textsnatcher { };
  tuba = pkgs.callPackage ./packages/tuba { };

  libmossSrc = pkgs.fetchFromGitHub {
    name = "libmoss";
    owner = "serpent-os";
    repo = "libmoss";
    rev = "v1.2.0";
    hash = "sha256-P7QUheCxwt7lTh3K1NEUas4TyojMrzTsNWj8UVQqkl0=";
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
