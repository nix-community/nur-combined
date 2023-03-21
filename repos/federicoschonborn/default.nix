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
  commit = pkgs.callPackage ./packages/commit {};
  devtoolbox = pkgs.callPackage ./packages/devtoolbox {};
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
  gitklient = pkgs.libsForQt5.callPackage ./packages/gitklient {};
  libxo = pkgs.callPackage ./packages/libxo {};
  liquidshell = pkgs.libsForQt5.callPackage ./packages/liquidshell {};
  morewaita = pkgs.callPackage ./packages/morewaita {};
  tooth = pkgs.callPackage ./packages/tooth {};

  loupe = pkgs.callPackage ./packages/loupe rec {
    gtk4 =
      if pkgs.lib.versionAtLeast pkgs.gtk4.version "4.10.1"
      then pkgs.gtk4
      else
        pkgs.gtk4.overrideAttrs (_: rec {
          version = "4.10.1";
          src = pkgs.fetchzip {
            url = "mirror://gnome/sources/gtk/${pkgs.lib.versions.majorMinor version}/gtk-${version}.tar.xz";
            hash = "sha256-fdNFilT/OB6izW6/QJlhl8wRC7mkANKVrvFR5vNJ++Q=";
          };
        });

    libadwaita =
      if pkgs.lib.versionAtLeast pkgs.libadwaita.version "1.3.1"
      then pkgs.libadwaita
      else
        (pkgs.libadwaita.overrideAttrs (_: rec {
          version = "1.3.1";
          src = pkgs.fetchzip {
            url = "mirror://gnome/sources/libadwaita/${pkgs.lib.versions.majorMinor version}/libadwaita-${version}.tar.xz";
            hash = "sha256-Pvk82qtqV29d1H6Xk6rnqPZfXDxYbO+jKj7QOEIGUIU=";
          };
        }))
        .override {inherit gtk4;};

    wrapGAppsHook4 = pkgs.wrapGAppsHook4.override {gtk3 = gtk4;};
  };
}
