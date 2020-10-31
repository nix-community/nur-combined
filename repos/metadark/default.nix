# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

with pkgs.lib;
let
  packages = (self:
let
  mergedPkgs = pkgs // self // { lib = pkgs.lib // self.lib; };
  callPackage = pkgs.newScope mergedPkgs;
in
with self; {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bcml = bcml-qt;

  bcml-gtk = python3Packages.callPackage ./pkgs/games/bcml {
    gui = "gtk";
    inherit msjt;
  };

  bcml-qt = python3Packages.callPackage ./pkgs/games/bcml {
    gui = "qt";
    inherit msjt;
    inherit (pkgs.qt5) wrapQtAppsHook;
  };

  bluetooth-autoconnect = python3Packages.callPackage ./pkgs/tools/bluetooth/bluetooth-autoconnect { };

  caprine = callPackage ./pkgs/applications/networking/instant-messengers/caprine {
    electron = pkgs.electron_9;
  };

  clonehero = clonehero-fhs-wrapper;
  clonehero-fhs-wrapper = callPackage ./pkgs/games/clonehero/fhs-wrapper.nix { };
  clonehero-unwrapped = callPackage ./pkgs/games/clonehero { };
  clonehero-xdg-wrapper = callPackage ./pkgs/games/clonehero/xdg-wrapper.nix { };

  cmake-language-server = python3Packages.callPackage ./pkgs/development/tools/misc/cmake-language-server { };

  emacs-pgtk-nativecomp = callPackage ./pkgs/applications/editors/emacs-pgtk-nativecomp { };

  git-review = pkgs.python3Packages.callPackage ./pkgs/applications/version-management/git-review { };

  goverlay = callPackage ./pkgs/tools/graphics/goverlay { };

  libhandy1 = callPackage ./pkgs/development/libraries/libhandy1 { };

  lightdm-webkit2-greeter = callPackage ./pkgs/applications/display-managers/lightdm-webkit2-greeter { };

  msjt = callPackage ./pkgs/tools/misc/msjt { };

  newsflash = callPackage ./pkgs/applications/networking/newsreaders/newsflash { };

  pokemmo-installer = callPackage ./pkgs/games/pokemmo-installer {
    inherit (pkgs.gnome3) zenity;
    jre = pkgs.jdk11;
  };

  protontricks = python3Packages.callPackage ./pkgs/tools/package-management/protontricks {
    inherit (pkgs.gnome3) zenity;
    wine = pkgs.wineWowPackages.minimal;
    winetricks = pkgs.winetricks.override {
      wine = pkgs.wineWowPackages.minimal;
    };
  };

  pythonPackages = recurseIntoAttrs (pkgs.makeOverridable (import ./pkgs/development/python-modules) {
    pkgs = mergedPkgs;
    pythonPackages = pkgs.pythonPackages;
  });

  python2Packages = recurseIntoAttrs (pythonPackages.override {
    pythonPackages = pkgs.python2Packages;
  });

  python3Packages = recurseIntoAttrs (pythonPackages.override {
    pythonPackages = pkgs.python3Packages;
  });

  python27Packages = recurseIntoAttrs (pythonPackages.override {
    pythonPackages = pkgs.python27Packages;
  });

  python37Packages = recurseIntoAttrs (pythonPackages.override {
    pythonPackages = pkgs.python37Packages;
  });

  python38Packages = recurseIntoAttrs (pythonPackages.override {
    pythonPackages = pkgs.python38Packages;
  });

  rofi-wayland = callPackage ./pkgs/applications/misc/rofi-wayland { };

  runescape-launcher-unwrapped = callPackage ./pkgs/games/runescape-launcher { };
  runescape-launcher = callPackage ./pkgs/games/runescape-launcher/wrapper.nix { };

  texlab = callPackage ./pkgs/development/tools/misc/texlab {
    inherit (pkgs.darwin.apple_sdk.frameworks) Security;
  };

  vkBasalt = callPackage ./pkgs/tools/graphics/vkBasalt {
    vkBasalt32 = pkgs.pkgsi686Linux.callPackage ./pkgs/tools/graphics/vkBasalt { };
  };

  VVVVVV-unwrapped = callPackage ./pkgs/games/VVVVVV {
    inherit (pkgs.darwin.apple_sdk.frameworks) Foundation;
  };

  VVVVVV = callPackage ./pkgs/games/VVVVVV/wrapper.nix {
    inherit (pkgs.darwin.apple_sdk.frameworks) Foundation;
  };

  wine-eac = callPackage ./pkgs/misc/emulators/wine-eac {
    wineBuild =
      if pkgs.stdenv.hostPlatform.system == "x86_64-linux"
      then "wineWow"
      else "wine32";
  };

  xpadneo = callPackage ./pkgs/os-specific/linux/xpadneo {
    kernel = pkgs.linux;
  };

  zynaddsubfx = zyn-fusion;

  zynaddsubfx-fltk = callPackage ./pkgs/applications/audio/zynaddsubfx {
    guiModule = "fltk";
  };

  zynaddsubfx-ntk = callPackage ./pkgs/applications/audio/zynaddsubfx {
    guiModule = "ntk";
  };

  zyn-fusion = callPackage ./pkgs/applications/audio/zynaddsubfx {
    guiModule = "zest";
  };
});
in
fix packages
