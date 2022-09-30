# This file describes your repository contents.  It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  # Per default, we should build against a stable version of nixpkgs
  # Note: Not using fetchFromGitHub because it comes from nixpkgs and we would import two versions
  #pkgs ? import (builtins.fetchTarball {
  #  name = "nixos-stable-20.03";
  #  url = "https://github.com/NixOS/nixpkgs/archive/5272327b81ed355bbed5659b8d303cf2979b6953.tar.gz";
  #  sha256 = "0182ys095dfx02vl2a20j1hz92dx3mfgz2a6fhn31bqlp1wa8hlq";
  #}) {}
  pkgs ? import <nixpkgs> {}
}:

pkgs.lib.makeExtensible (self:
  pkgs.lib.traceValFn (x:
   "Nixpkgs version : ${pkgs.lib.version}"
  )
rec {
  inherit pkgs;

  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = pkgs.lib.traceVal (import ./overlays); # nixpkgs overlays

  tests = import ./tests { inherit pkgs; instantnix = self; };

  # instant WM and utils
  argtable3 = pkgs.callPackage ./pkgs/argtable3 { };
  disper = pkgs.callPackage ./pkgs/disper { };
  gufw = with pkgs.python3Packages; pkgs.callPackage ./pkgs/gufw { inherit buildPythonApplication distutils_extra; };
  imenu = pkgs.callPackage ./pkgs/imenu { instantMenu = self.instantmenu; };
  instantconf = pkgs.callPackage ./pkgs/instantConf { };
  instantlock = pkgs.callPackage ./pkgs/instantLock {
    instantMenu = self.instantmenu;
    argtable3 = argtable3;
  };
  instantlogo = pkgs.callPackage ./pkgs/instantLogo { };
  instantshell = pkgs.callPackage ./pkgs/instantShell { };
  instantwidgets = pkgs.callPackage ./pkgs/instantWidgets { };
  lxsession = pkgs.callPackage ./pkgs/lxsession { };
  paperbash = pkgs.callPackage ./pkgs/Paperbash { };
  rangerplugins = pkgs.callPackage ./pkgs/rangerplugins { };
  spotify-adblock = pkgs.callPackage ./pkgs/spotify-adblock { };
  instantassist = pkgs.callPackage ./pkgs/instantAssist {
    instantConf = instantconf;
    spotify-adblock = self.spotify-adblock;
  };
  islide = pkgs.callPackage ./pkgs/islide {
    instantAssist = self.instantassist;
  };
  instantthemes = pkgs.callPackage ./pkgs/instantThemes {
    Paperbash = self.paperbash;
  };
  instantutils = pkgs.callPackage ./pkgs/instantUtils {
    inherit lxsession rangerplugins disper;
    inherit (pkgs.xfce) xfce4-power-manager;
    inherit (pkgs.gnome) zenity;
  };
  instantmenu = pkgs.callPackage ./pkgs/instantMenu {
    instantUtils = self.instantutils;
  };
  instantnotify = pkgs.callPackage ./pkgs/instantNotify {
    instantMenu = self.instantmenu;
  };
  instantwallpaper = pkgs.callPackage ./pkgs/instantWallpaper {
    instantLogo = self.instantlogo;
    instantConf = self.instantconf;
    instantUtils = self.instantutils;
    Paperbash = self.paperbash;
    inherit (pkgs.gnome) zenity;
  };
  instantsettings = with pkgs.python3Packages; pkgs.callPackage ./pkgs/instantSettings {
    instantAssist = self.instantassist;
    instantConf = self.instantconf;
    instantUtils = self.instantutils;
    instantWallpaper = self.instantwallpaper;
    gufw = self.gufw;
    gnome-disk-utility = pkgs.gnome.gnome-disk-utility;
    xfce4-power-manager = pkgs.xfce.xfce4-power-manager;
    firaCodeNerd = self.firacodenerd;
  };
  instantwelcome = with pkgs.python3Packages; pkgs.callPackage ./pkgs/instantWelcome {
    instantConf = self.instantconf;
    buildPythonApplication = buildPythonApplication;
    pygobject3 = pygobject3;
  };
  instantdotfiles = pkgs.callPackage ./pkgs/instantDotfiles {
    instantConf = self.instantconf;
    instantWallpaper = self.instantwallpaper;
  };
  instantwm = pkgs.callPackage ./pkgs/instantWm {
    instantAssist = self.instantassist;
    instantUtils = self.instantutils;
    instantDotfiles = self.instantdotfiles;
  };
  instantwm-fr = pkgs.callPackage ./pkgs/instantWm {
    instantAssist = self.instantassist;
    instantUtils = self.instantutils;
    instantDotfiles = self.instantdotfiles;
    extraPatches = [ ./pkgs/instantWm/french-keybindings.patch ];
  };
  firacodenerd = (pkgs.nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; });
  instantst = pkgs.callPackage ./pkgs/instantSt { firacodenerd = self.firacodenerd; };
  instantdata = pkgs.callPackage ./pkgs/instantData {
    instantAssist = self.instantassist;
    instantConf = self.instantconf;
    instantDotfiles = self.instantdotfiles;
    instantLogo = self.instantlogo;
    instantMenu = self.instantmenu;
    instantShell = self.instantshell;
    instantThemes = self.instantthemes;
    instantUtils = self.instantutils;
    instantWallpaper = self.instantwallpaper;
    instantWidgets = self.instantwidgets;
    instantWm = self.instantwm;
    Paperbash = self.paperbash;
    rangerplugins = self.rangerplugins;
  };
  instantnix = pkgs.buildEnv {
    name = "instantnix";
    meta = with pkgs.lib; {
      description = "instantOS metapackage for Nix";
      license = licenses.mit;
      homepage = "https://github.com/instantOS/instantOS";
      maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
      platforms = platforms.linux;
    };
    paths = [
        self.imenu
        self.islide
        self.instantassist
        self.instantconf
        self.instantdata
        self.instantdotfiles
        self.instantlock
        self.instantlogo
        self.instantmenu
        self.instantnotify
        self.instantsettings
        self.instantshell
        self.instantthemes
        self.instantutils
        self.instantwallpaper
        self.instantwelcome
        self.instantwidgets
        self.instantwm
        self.instantst
        self.paperbash
        self.rangerplugins
        self.spotify-adblock
        self.pkgs.dash
        self.pkgs.xdg-user-dirs
        self.pkgs.papirus-icon-theme
        self.pkgs.arc-theme
        pkgs.xorg.xeyes
    ];
  };
} )

