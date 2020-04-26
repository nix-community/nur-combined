# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # applications/graphics
  steamgrid = pkgs.callPackage ./pkgs/applications/graphics/steamgrid { };

  # applications/misc
  minigalaxy = pkgs.python3.pkgs.callPackage ./pkgs/applications/misc/minigalaxy { };

  # development/mobile
  qdl = pkgs.callPackage ./pkgs/development/mobile/qdl { };

  # misc/emulators
  citra = pkgs.libsForQt5.callPackage ./pkgs/misc/emulators/citra { };
  dosbox-staging = pkgs.callPackage ./pkgs/misc/emulators/dosbox-staging { };
  yuzu = pkgs.libsForQt5.callPackage ./pkgs/misc/emulators/yuzu {};

  # tools/audio
  vban = pkgs.callPackage ./pkgs/tools/audio/vban { };

  # tools/misc
  libspeedhack = pkgs.callPackage ./pkgs/tools/misc/libspeedhack { };
  samrewritten = pkgs.callPackage ./pkgs/tools/misc/samrewritten { };
  sbase = pkgs.callPackage ./pkgs/tools/misc/sbase { };
  ubase = pkgs.callPackage ./pkgs/tools/misc/ubase { };
}
