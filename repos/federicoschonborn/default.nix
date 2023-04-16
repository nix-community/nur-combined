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
  firefox-gnome-theme = pkgs.callPackage ./packages/firefox-gnome-theme {};
  gitklient = pkgs.libsForQt5.callPackage ./packages/gitklient {};
  libxo = pkgs.callPackage ./packages/libxo {};
  liquidshell = pkgs.libsForQt5.callPackage ./packages/liquidshell {};
  morewaita = pkgs.callPackage ./packages/morewaita {};
  opensurge = pkgs.callPackage ./packages/opensurge {inherit surgescript;};
  surgescript = pkgs.callPackage ./packages/surgescript {};
  tuba = pkgs.callPackage ./packages/tuba {};
}
