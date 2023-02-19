# This file built for flake-kind build

{ pkgs }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  Graphite-cursors = pkgs.callPackage ./pkgs/Graphite-cursors { };
  rustplayer = pkgs.callPackage ./pkgs/RustPlayer { };
  sing-box = pkgs.callPackage ./pkgs/sing-box { };
  oppo-sans = pkgs.callPackage ./pkgs/oppo-sans { };
  san-francisco = pkgs.callPackage ./pkgs/san-francisco { };
  v2ray-plugin = pkgs.callPackage ./pkgs/v2ray-plugin { };
  plangothic = pkgs.callPackage ./pkgs/plangothic { };
  maple-font = pkgs.callPackage ./pkgs/maple-font { };
  surrealdb = pkgs.callPackage ./pkgs/surrealdb { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  maoken-tangyuan = pkgs.callPackage ./pkgs/maoken-tangyuan { };
  shadow-tls = pkgs.callPackage ./pkgs/shadow-tls { };
  tuic = pkgs.callPackage ./pkgs/tuic { };
  techmino = pkgs.callPackage ./pkgs/techmino { };
  naiveproxy = pkgs.callPackage ./pkgs/naiveproxy { };
#  chatgpt = pkgs.callPackage ./pkgs/chatgpt { };
  # dm-sflc-modules = pkgs.callPackage ./pkgs/dm-sflc-modules { };

  # ...
}
