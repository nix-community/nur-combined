# This file describes your repository contents.  It should return a set of nix derivations
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
  
  # Instant WM and utils
  instantconf = pkgs.callPackage ./pkgs/InstantConf { };
  instantlogo = pkgs.callPackage ./pkgs/InstantLOGO { };
  instantshell = pkgs.callPackage ./pkgs/InstantShell { };
  instantwidgets = pkgs.callPackage ./pkgs/InstantWidgets { };
  paperbash = pkgs.callPackage ./pkgs/Paperbash { };
  rangerplugins = pkgs.callPackage ./pkgs/rangerplugins { };
  spotify-adblock = pkgs.callPackage ./pkgs/spotify-adblock { };
  instantassist = pkgs.callPackage ./pkgs/InstantASSIST {
    Paperbash = paperbash;
    spotify-adblock = spotify-adblock;
  };
  islide = pkgs.callPackage ./pkgs/islide {
    InstantASSIST = instantassist;
  };
  instantthemes = pkgs.callPackage ./pkgs/InstantTHEMES {
    Paperbash = paperbash;
  };
  instantutils = pkgs.callPackage ./pkgs/InstantUtils { 
    rangerplugins = rangerplugins;
  };
  instantmenu = pkgs.callPackage ./pkgs/InstantMENU {
    InstantUtils = instantutils;
  };
  instantwallpaper = pkgs.callPackage ./pkgs/InstantWallpaper {
    InstantLOGO = instantlogo;
    InstantConf = instantconf;
    InstantUtils = instantutils;
    Paperbash = paperbash;
  };
  instantdotfiles = pkgs.callPackage ./pkgs/InstantDotfiles {
    InstantConf = instantconf;
    InstantWALLPAPER = instantwallpaper;
  };
  instantwm = pkgs.callPackage ./pkgs/InstantWM {
    InstantUtils = instantutils;
  };
  instantdata = pkgs.callPackage ./pkgs/InstantData {
    InstantConf = instantconf;
    InstantDotfiles = instantdotfiles;
    InstantLOGO  = instantlogo;
    InstantMENU = instantmenu;
    InstantShell = instantshell;
    InstantTHEMES = instantthemes;
    InstantUtils = instantutils;
    InstantWALLPAPER = instantwallpaper;
    InstantWidgets = instantwidgets;
    InstantWM = instantwm;
    Paperbash = paperbash;
    rangerplugins = rangerplugins;
  };
}

