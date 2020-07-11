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

  # instant WM and utils
  instantconf = pkgs.callPackage ./pkgs/instantConf { };
  instantlogo = pkgs.callPackage ./pkgs/instantLOGO { };
  instantshell = pkgs.callPackage ./pkgs/instantShell { };
  instantwidgets = pkgs.callPackage ./pkgs/instantWidgets { };
  paperbash = pkgs.callPackage ./pkgs/Paperbash { };
  imenu = pkgs.callPackage ./pkgs/imenu { instantMENU = instantmenu; };
  rangerplugins = pkgs.callPackage ./pkgs/rangerplugins { };
  spotify-adblock = pkgs.callPackage ./pkgs/spotify-adblock { };
  instantassist = pkgs.callPackage ./pkgs/instantASSIST {
    Paperbash = paperbash;
    spotify-adblock = spotify-adblock;
  };
  islide = pkgs.callPackage ./pkgs/islide {
    instantASSIST = instantassist;
  };
  instantthemes = pkgs.callPackage ./pkgs/instantTHEMES {
    Paperbash = paperbash;
  };
  instantutils = pkgs.callPackage ./pkgs/instantUtils { 
    rangerplugins = rangerplugins;
    xfce4-power-manager = pkgs.xfce.xfce4-power-manager;
  };
  instantmenu = pkgs.callPackage ./pkgs/instantMENU {
    instantUtils = instantutils;
  };
  instantwallpaper = pkgs.callPackage ./pkgs/instantWallpaper {
    instantLOGO = instantlogo;
    instantConf = instantconf;
    instantUtils = instantutils;
    Paperbash = paperbash;
  };
  instantsettings = with pkgs.python3Packages; pkgs.callPackage ./pkgs/instantSettings {
    instantASSIST = instantassist;
    instantConf = instantconf;
    instantWALLPAPER = instantwallpaper;
    buildPythonApplication = buildPythonApplication;
    pygobject3 = pygobject3;
    gnome-disk-utility = pkgs.gnome3.gnome-disk-utility;
    xfce4-power-manager = pkgs.xfce.xfce4-power-manager;
  };
  instantwelcome = with pkgs.python3Packages; pkgs.callPackage ./pkgs/instantWELCOME {
    instantConf = instantconf;
    buildPythonApplication = buildPythonApplication;
    pygobject3 = pygobject3;
  };
  instantdotfiles = pkgs.callPackage ./pkgs/instantDotfiles {
    instantConf = instantconf;
    instantWALLPAPER = instantwallpaper;
  };
  instantwm = pkgs.callPackage ./pkgs/instantWM {
    instantASSIST = instantassist;
    instantUtils = instantutils;
  };
  instantdata = pkgs.callPackage ./pkgs/instantData {
    instantASSIST = instantassist;
    instantConf = instantconf;
    instantDotfiles = instantdotfiles;
    instantLOGO  = instantlogo;
    instantMENU = instantmenu;
    instantShell = instantshell;
    instantTHEMES = instantthemes;
    instantUtils = instantutils;
    instantWALLPAPER = instantwallpaper;
    instantWidgets = instantwidgets;
    instantWM = instantwm;
    Paperbash = paperbash;
    rangerplugins = rangerplugins;
  };
  instantixos = pkgs.buildEnv {
    name = "instantixos";
    meta = with pkgs.lib; {
      description = "instantOS metapackage for Nix";
      license = licenses.mit;
      homepage = "https://github.com/instantOS/instantOS";
      maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
      platforms = platforms.linux;
    };
    paths = [
        imenu
        instantassist
        instantconf
        instantdata
        instantdotfiles
        instantlogo
        instantmenu
        instantsettings
        instantshell
        instantthemes
        instantutils
        instantwallpaper
        instantwelcome
        instantwidgets
        instantwm
        paperbash
        rangerplugins
        spotify-adblock
    ];
  };
}

