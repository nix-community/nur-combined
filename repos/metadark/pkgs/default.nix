{ pkgs }:

let nurPkgs = (mergedPkgs:
let
  callPackage = pkgs.newScope mergedPkgs;
in
with mergedPkgs; {
  inherit callPackage;

  bcml = bcml-qt;

  bcml-gtk = python3Packages.callPackage ./games/bcml {
    gui = "gtk";
    wrapQtAppsHook = null;
  };

  bcml-qt = python3Packages.callPackage ./games/bcml {
    gui = "qt";
    inherit (qt5) wrapQtAppsHook;
  };

  bluetooth-autoconnect = python3Packages.callPackage ./tools/bluetooth/bluetooth-autoconnect { };

  caprine = callPackage ./applications/networking/instant-messengers/caprine { };

  ccache = callPackage ./tools/misc/ccache {
    asciidoc = asciidoc-full;
  };

  clonehero = clonehero-fhs-wrapper;
  clonehero-fhs-wrapper = callPackage ./games/clonehero/fhs-wrapper.nix { };
  clonehero-unwrapped = callPackage ./games/clonehero { };
  clonehero-xdg-wrapper = callPackage ./games/clonehero/xdg-wrapper.nix { };

  cmake-language-server = python3Packages.callPackage ./development/tools/misc/cmake-language-server { };

  emacs-pgtk = callPackage ./applications/editors/emacs-pgtk { };
  emacs-pgtk-native-comp = emacs-pgtk;

  git-review = python3Packages.callPackage ./applications/version-management/git-review { };

  goverlay = callPackage ./tools/graphics/goverlay { };

  lightdm-webkit2-greeter = callPackage ./applications/display-managers/lightdm-webkit2-greeter { };

  mangohud = callPackage ./tools/graphics/mangohud rec {
    libXNVCtrl = linuxPackages.nvidia_x11.settings.libXNVCtrl;
    mangohud32 = pkgsi686Linux.callPackage ./tools/graphics/mangohud {
      libXNVCtrl = linuxPackages.nvidia_x11.settings.libXNVCtrl;
      inherit mangohud32;
      inherit (pkgs) python3Packages;
    };
    inherit (pkgs) python3Packages;
  };

  newsflash = callPackage ./applications/networking/newsreaders/newsflash { };

  poke = callPackage ./applications/editors/poke { };

  pokemmo-installer = callPackage ./games/pokemmo-installer {
    inherit (gnome) zenity;
    jre = jdk11;
  };

  protontricks = python3Packages.callPackage ./tools/package-management/protontricks {
    inherit steam-run;
    inherit winetricks;
    inherit (gnome) zenity;
  };

  pythonPackages = makeOverridable (import ./development/python-modules) {
    inherit mergedPkgs;
    pythonPackages = pkgs.pythonPackages;
  };

  python2Packages = pythonPackages.override {
    pythonPackages = pkgs.python2Packages;
  };

  python3Packages = pythonPackages.override {
    pythonPackages = pkgs.python3Packages;
  };

  python27Packages = pythonPackages.override {
    pythonPackages = pkgs.python27Packages;
  };

  python37Packages = pythonPackages.override {
    pythonPackages = pkgs.python37Packages;
  };

  python38Packages = pythonPackages.override {
    pythonPackages = pkgs.python38Packages;
  };

  python39Packages = pythonPackages.override {
    pythonPackages = pkgs.python39Packages;
  };

  python310Packages = pythonPackages.override {
    pythonPackages = pkgs.python310Packages;
  };

  rofi-wayland = callPackage ./applications/misc/rofi-wayland { };

  runescape-launcher = callPackage ./games/runescape-launcher/wrapper.nix { };
  runescape-launcher-unwrapped = callPackage ./games/runescape-launcher { };

  texlab = callPackage ./development/tools/misc/texlab {
    inherit (darwin.apple_sdk.frameworks) Security;
  };

  themes = callPackage ./data/themes { };

  undistract-me = callPackage ./shells/bash/undistract-me { };

  virtualparadise = callPackage ./games/virtualparadise {
    inherit (qt5) wrapQtAppsHook;
  };

  vkBasalt = callPackage ./tools/graphics/vkBasalt rec {
    vkBasalt32 = pkgsi686Linux.callPackage ./tools/graphics/vkBasalt {
      inherit vkBasalt32;
    };
  };

  VVVVVV = callPackage ./games/VVVVVV/wrapper.nix {
    inherit (darwin.apple_sdk.frameworks) Foundation;
  };

  VVVVVV-unwrapped = callPackage ./games/VVVVVV {
    inherit (darwin.apple_sdk.frameworks) Foundation;
  };

  xpadneo = callPackage ./os-specific/linux/xpadneo {
    kernel = linux;
  };

  yabridge = callPackage ./tools/audio/yabridge {
    wine = wineWowPackages.staging;
  };

  yabridgectl = callPackage ./tools/audio/yabridgectl {
    wine = wineWowPackages.staging;
  };

  zynaddsubfx = zyn-fusion;

  zynaddsubfx-fltk = callPackage ./applications/audio/zynaddsubfx {
    guiModule = "fltk";
  };

  zynaddsubfx-ntk = callPackage ./applications/audio/zynaddsubfx {
    guiModule = "ntk";
  };

  zyn-fusion = callPackage ./applications/audio/zynaddsubfx {
    guiModule = "zest";
  };
}) (pkgs // nurPkgs);
in
nurPkgs
