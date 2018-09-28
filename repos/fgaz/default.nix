# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ### DEVELOPMENT
  lmdbxx = pkgs.callPackage ./pkgs/lmdbxx { };

  ### SERVERS
  pleroma = pkgs.callPackage ./pkgs/pleroma { };

  ### APPLICATIONS
  variety = pkgs.callPackage ./pkgs/variety { };
  gnubiff = pkgs.callPackage ./pkgs/gnubiff { };
  maya-calendar = pkgs.callPackage ./pkgs/maya-calendar { };
  sfxr = pkgs.callPackage ./pkgs/sfxr { };
  sfxr-qt = pkgs.libsForQt5.callPackage ./pkgs/sfxr-qt { };
  powerline-go = pkgs.powerline-go.overrideDerivation (old: {
    src = pkgs.fetchFromGitHub {
      owner = "fgaz";
      repo = "powerline-go";
      rev = "ghc-env";
      sha256 = "0l68v75bfl7nzlc43bh6nyx3akdaj6ac0qnd0r0lagppspm4i6hh";
    };
  });

  ### GAMES
  _20kly = pkgs.callPackage ./pkgs/20kly { };
  endgame-singularity = pkgs.callPackage ./pkgs/endgame-singularity { };
  openhexagon = pkgs.callPackage ./pkgs/openhexagon { };
  powermanga = pkgs.libsForQt5.callPackage ./pkgs/powermanga { };
}

