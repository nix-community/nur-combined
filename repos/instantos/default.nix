# This file describes your repository contents.  It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  # Per default, we should build against a stable version of nixpkgs
  # Note: Not using fetchFromGitHub because it comes from nixpkgs and we would import two versions
  pkgs ? import (builtins.fetchTarball {
    name = "nixos-stable-20.03";
    url = "https://github.com/NixOS/nixpkgs/archive/5272327b81ed355bbed5659b8d303cf2979b6953.tar.gz";
    sha256 = "0182ys095dfx02vl2a20j1hz92dx3mfgz2a6fhn31bqlp1wa8hlq";
  }) {}
  #pkgs ? import <nixpkgs> {}
}:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # instant WM and utils
  instantconf = pkgs.callPackage ./pkgs/instantConf { };
  instantlogo = pkgs.callPackage ./pkgs/instantLogo { };
  instantshell = pkgs.callPackage ./pkgs/instantShell { };
  instantwidgets = pkgs.callPackage ./pkgs/instantWidgets { };
  paperbash = pkgs.callPackage ./pkgs/Paperbash { };
  imenu = pkgs.callPackage ./pkgs/imenu { instantMenu = instantmenu; };
  rangerplugins = pkgs.callPackage ./pkgs/rangerplugins { };
  spotify-adblock = pkgs.callPackage ./pkgs/spotify-adblock { };
  instantassist = pkgs.callPackage ./pkgs/instantAssist {
    Paperbash = paperbash;
    spotify-adblock = spotify-adblock;
  };
  islide = pkgs.callPackage ./pkgs/islide {
    instantAssist = instantassist;
  };
  instantthemes = pkgs.callPackage ./pkgs/instantThemes {
    Paperbash = paperbash;
  };
  instantutils = pkgs.callPackage ./pkgs/instantUtils { 
    rangerplugins = rangerplugins;
    xfce4-power-manager = pkgs.xfce.xfce4-power-manager;
    zenity = pkgs.gnome3.zenity;
  };
  instantmenu = pkgs.callPackage ./pkgs/instantMenu {
    instantUtils = instantutils;
  };
  instantwallpaper = pkgs.callPackage ./pkgs/instantWallpaper {
    instantLogo = instantlogo;
    instantConf = instantconf;
    instantUtils = instantutils;
    Paperbash = paperbash;
  };
  instantsettings = with pkgs.python3Packages; pkgs.callPackage ./pkgs/instantSettings {
    instantAssist = instantassist;
    instantConf = instantconf;
    instantWallpaper = instantwallpaper;
    buildPythonApplication = buildPythonApplication;
    pygobject3 = pygobject3;
    gnome-disk-utility = pkgs.gnome3.gnome-disk-utility;
    xfce4-power-manager = pkgs.xfce.xfce4-power-manager;
  };
  instantwelcome = with pkgs.python3Packages; pkgs.callPackage ./pkgs/instantWelcome {
    instantConf = instantconf;
    buildPythonApplication = buildPythonApplication;
    pygobject3 = pygobject3;
  };
  instantdotfiles = pkgs.callPackage ./pkgs/instantDotfiles {
    instantConf = instantconf;
    instantWallpaper = instantwallpaper;
  };
  instantwm = pkgs.callPackage ./pkgs/instantWm {
    instantAssist = instantassist;
    instantUtils = instantutils;
    instantDotfiles = instantdotfiles;
  };
  instantdata = pkgs.callPackage ./pkgs/instantData {
    instantAssist = instantassist;
    instantConf = instantconf;
    instantDotfiles = instantdotfiles;
    instantLogo  = instantlogo;
    instantMenu = instantmenu;
    instantShell = instantshell;
    instantThemes = instantthemes;
    instantUtils = instantutils;
    instantWallpaper = instantwallpaper;
    instantWidgets = instantwidgets;
    instantWm = instantwm;
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
        islide
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

