# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ab-download-manager = pkgs.callPackage ./pkgs/abdm {};
  beeper-nightly = pkgs.callPackage ./pkgs/beeper-nightly {};
  boxtron-bin = pkgs.callPackage ./pkgs/boxtron-bin {};
  hyprcursor-bibata = pkgs.callPackage ./pkgs/hyprcursor-bibata {};
  hyprpanel = pkgs.callPackage ./pkgs/hyprpanel {};
  moonplayer = pkgs.callPackage ./pkgs/moonplayer {};
  nirius = pkgs.callPackage ./pkgs/nirius {};
  osu-tachyon = pkgs.callPackage ./pkgs/osu-tachyon {};
  proton-em-bin = pkgs.callPackage ./pkgs/proton-em-bin {};
  proton-ge-rtsp-bin = pkgs.callPackage ./pkgs/proton-ge-rtsp-bin {};
  proton-sarek-bin = pkgs.callPackage ./pkgs/proton-sarek-bin {};
  re-lunatic-player = pkgs.callPackage ./pkgs/re-lunatic-player {};
  syslock = pkgs.callPackage ./pkgs/syslock {};
  waterfox-bin = pkgs.callPackage ./pkgs/waterfox-bin {};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
