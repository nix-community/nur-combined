# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays


  controls-for-fake = pkgs.libsForQt5.callPackage ./pkgs/ControlsForFake  {
    FakeMicWavPlayer = fake-mic-wav-player;
  };
  day-night-plasma-wallpapers = pkgs.callPackage ./pkgs/day-night-plasma-wallpapers { 
    dbus-python = pkgs.python3Packages.dbus-python;
  };
  scripts = pkgs.callPackage ./pkgs/Scripts {
    eom = pkgs.mate.eom;
  };
  spectacle-clipboard = pkgs.libsForQt5.callPackage ./pkgs/spectacle-clipboard { };
  fake-mic-wav-player = pkgs.libsForQt5.callPackage ./pkgs/FakeMicWavPlayer { };
  inkscape = pkgs.callPackage ./pkgs/inkscape-1.0 { 
    lcms = pkgs.lcms2;
  };
  lokalize = pkgs.libsForQt5.callPackage ./pkgs/Lokalize { };
  ksmoothdock = pkgs.libsForQt5.callPackage ./pkgs/ksmoothdock { };
  keysmith = pkgs.kdeApplications.callPackage ./pkgs/keysmith { };

}

