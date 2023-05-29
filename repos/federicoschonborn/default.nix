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
  brisk-menu = pkgs.callPackage ./packages/brisk-menu { };
  bsdutils = pkgs.callPackage ./packages/bsdutils { inherit libxo; };
  cargo-aoc = pkgs.callPackage ./packages/cargo-aoc { };
  chess-clock = pkgs.callPackage ./packages/chess-clock { };
  damask = pkgs.callPackage ./packages/damask { };
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
  gradebook = pkgs.callPackage ./packages/gradebook { };
  health = pkgs.callPackage ./packages/health { };
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
  loupe = pkgs.callPackage ./packages/loupe {
    gtk4 = gtk4_11;
    wrapGAppsHook4 = wrapGAppsHook4_11;
  };
  metronome = pkgs.callPackage ./packages/metronome { };
  morewaita = pkgs.callPackage ./packages/morewaita { };
  mucalc = pkgs.callPackage ./packages/mucalc { };
  opensurge = pkgs.callPackage ./packages/opensurge { inherit surgescript; };
  qv = pkgs.qt6.callPackage ./packages/qv { inherit libtgd; };
  share-preview = pkgs.callPackage ./packages/share-preview { };
  snapshot = pkgs.callPackage ./packages/snapshot {
    gtk4 = gtk4_11;
    libadwaita = libadwaita_1_4;
    wrapGAppsHook4 = wrapGAppsHook4_11;
  };
  srb2p = pkgs.callPackage ./packages/srb2p { };
  surgescript = pkgs.callPackage ./packages/surgescript { };
  telegraph = pkgs.callPackage ./packages/telegraph { };
  textsnatcher = pkgs.callPackage ./packages/textsnatcher { };
  tuba = pkgs.callPackage ./packages/tuba { };

  wrapGAppsHook4_11 = pkgs.wrapGAppsHook4.override { gtk3 = gtk4_11; };

  gtk4_11 = pkgs.gtk4.overrideAttrs (oldAttrs: rec {
    version = "4.11.2";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "GNOME";
      repo = "gtk";
      rev = version;
      hash = "sha256-kkT/gr+kykoZplyY49TXmS49n34IrZmmLuPneqVRfNU=";
    };
    patches = [];
    postPatch = (oldAttrs.postPatch or "") + ''
      patchShebangs build-aux/meson/gen-visibility-macros.py
    '';
    doCheck = false;
  });

  libadwaita_1_4 = (pkgs.libadwaita.overrideAttrs (oldAttrs: {
    version = "unstable-2023-05-16";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "GNOME";
      repo = "libadwaita";
      rev = "2071c461f2a7d4a7e1db17a0963b9fd4685f625d";
      hash = "sha256-ibUtzFCiUeYwu3gbpv1XWgfBalDgqHZFagEalK6eEac=";
    };
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.appstream ];
    doCheck = false;
  })).override { gtk4 = gtk4_11; };
}
