# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bsdutils = pkgs.callPackage ./packages/bsdutils {inherit libxo;};
  cargo-aoc = pkgs.callPackage ./packages/cargo-aoc {};
  devtoolbox = pkgs.callPackage ./packages/devtoolbox {};
  elastic = pkgs.callPackage ./packages/elastic {};
  fastfetch = pkgs.callPackage ./packages/fastfetch {};
  fastfetchFull = fastfetch.override {
    enableLibpci = true;
    enableVulkan = true;
    enableWayland = true;
    enableXcb = true;
    enableXrandr = true;
    enableX11 = true;
    enableGio = true;
    enableDconf = true;
    enableDbus = true;
    enableXfconf = true;
    enableSqlite3 = true;
    enableRpm = true;
    enableImagemagick7 = true;
    enableZlib = true;
    enableChafa = true;
    enableEgl = true;
    enableGlx = true;
    enableMesa = true;
    enableOpencl = true;
    enableLibcjson = true;
    enableLibnm = true;
    enableFreetype = true;
    enablePulse = true;
  };
  firefox-gnome-theme = pkgs.callPackage ./packages/firefox-gnome-theme {};
  kommit = pkgs.libsForQt5.callPackage ./packages/kommit {};
  libxo = pkgs.callPackage ./packages/libxo {};
  liquidshell = pkgs.libsForQt5.callPackage ./packages/liquidshell {};
  loupe = pkgs.callPackage ./packages/loupe {gtk4 = gtk4_11;};
  morewaita = pkgs.callPackage ./packages/morewaita {};
  opensurge = pkgs.callPackage ./packages/opensurge {inherit surgescript;};
  snapshot = pkgs.callPackage ./packages/snapshot {
    gtk4 = gtk4_11;
    libadwaita = libadwaita1_4;
  };
  surgescript = pkgs.callPackage ./packages/surgescript {};
  telegraph = pkgs.callPackage ./packages/telegraph {};
  tuba = pkgs.callPackage ./packages/tuba {};

  gtk4_11 = pkgs.gtk4.overrideAttrs (_: {
    version = "unstable-2023-05-07";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "GNOME";
      repo = "gtk";
      rev = "61ff647f71879f20da4b8b4d71d6b11c8ae6d391";
      hash = "sha256-zZoy/oFzW+lmJJhXOV3K3DIxDjhLVhWUG2zIi33+Z6o=";
    };
  });

  libadwaita1_4 =
    (pkgs.libadwaita.overrideAttrs (oldAttrs: {
      version = "unstable-2023-05-07";
      src = pkgs.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "libadwaita";
        rev = "a98da7cf5dac823b155191f0be76cc1b2d8002c3";
        hash = "sha256-ufxtxUcsMYfGK0UETwVK+xnqQ1E2UsaLpSbYoqmHCeg=";
      };
      buildInputs = oldAttrs.buildInputs ++ [pkgs.appstream];
      dontCheck = true;
    }))
    .override {gtk4 = gtk4_11;};
}
