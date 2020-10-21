# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bluetooth-autoconnect = pkgs.python3Packages.callPackage ./pkgs/tools/bluetooth/bluetooth-autoconnect { };

  caprine = pkgs.callPackage ./pkgs/applications/networking/instant-messengers/caprine {
    electron = pkgs.electron_9;
  };

  clonehero-unwrapped = pkgs.callPackage ./pkgs/games/clonehero { };

  clonehero-xdg-wrapper = pkgs.callPackage ./pkgs/games/clonehero/xdg-wrapper.nix {
    inherit clonehero-unwrapped;
  };

  clonehero-fhs-wrapper = pkgs.callPackage ./pkgs/games/clonehero/fhs-wrapper.nix {
    inherit clonehero-unwrapped clonehero-xdg-wrapper;
  };

  clonehero = clonehero-fhs-wrapper;

  cmake-language-server = pkgs.python3Packages.callPackage ./pkgs/development/tools/misc/cmake-language-server {
    inherit pygls pytest-datadir;
  };

  debugpy = pkgs.python3Packages.callPackage ./pkgs/development/python-modules/debugpy { };

  emacs-pgtk-nativecomp = pkgs.callPackage ./pkgs/applications/editors/emacs-pgtk-nativecomp { };

  goverlay = pkgs.callPackage ./pkgs/tools/graphics/goverlay { };

  libhandy1 = pkgs.callPackage ./pkgs/development/libraries/libhandy1 { };

  lightdm-webkit2-greeter = pkgs.callPackage ./pkgs/applications/display-managers/lightdm-webkit2-greeter {
    inherit lightdm-webkit2-greeter;
  };

  newsflash = pkgs.callPackage ./pkgs/applications/networking/newsreaders/newsflash { };

  pokemmo-installer = pkgs.callPackage ./pkgs/games/pokemmo-installer {
    inherit (pkgs.gnome3) zenity;
    jre = pkgs.jdk11;
  };

  protontricks = pkgs.python3Packages.callPackage ./pkgs/tools/package-management/protontricks {
    inherit (pkgs.gnome3) zenity;
    wine = pkgs.wineWowPackages.minimal;
    winetricks = pkgs.winetricks.override {
      wine = pkgs.wineWowPackages.minimal;
    };
  };

  pygls = pkgs.python3Packages.callPackage ./pkgs/development/python-modules/pygls { };

  pytest-datadir = pkgs.python3Packages.callPackage ./pkgs/development/python-modules/pytest-datadir { };

  rofi-wayland = pkgs.callPackage ./pkgs/applications/misc/rofi-wayland { };

  runescape-launcher-unwrapped = pkgs.callPackage ./pkgs/games/runescape-launcher { };

  runescape-launcher = pkgs.callPackage ./pkgs/games/runescape-launcher/wrapper.nix { };

  texlab = pkgs.callPackage ./pkgs/development/tools/misc/texlab {
    inherit (pkgs.darwin.apple_sdk.frameworks) Security;
  };

  vdf = pkgs.python3Packages.callPackage ./pkgs/development/python-modules/vdf { };

  vkBasalt = pkgs.callPackage ./pkgs/tools/graphics/vkBasalt {
    vkBasalt32 = pkgs.pkgsi686Linux.callPackage ./pkgs/tools/graphics/vkBasalt { };
  };

  VVVVVV-unwrapped = pkgs.callPackage ./pkgs/games/VVVVVV {
    inherit (pkgs.darwin.apple_sdk.frameworks) Foundation;
  };

  VVVVVV = pkgs.callPackage ./pkgs/games/VVVVVV/wrapper.nix {
    inherit (pkgs.darwin.apple_sdk.frameworks) Foundation;
  };

  wine-eac = pkgs.callPackage ./pkgs/misc/emulators/wine-eac {
    wineBuild =
      if pkgs.stdenv.hostPlatform.system == "x86_64-linux"
      then "wineWow"
      else "wine32";
  };

  xpadneo = pkgs.callPackage ./pkgs/os-specific/linux/xpadneo {
    kernel = pkgs.linux;
  };

  zynaddsubfx = zyn-fusion;

  zynaddsubfx-fltk = pkgs.callPackage ./pkgs/applications/audio/zynaddsubfx {
    guiModule = "fltk";
  };

  zynaddsubfx-ntk = pkgs.callPackage ./pkgs/applications/audio/zynaddsubfx {
    guiModule = "ntk";
  };

  zyn-fusion = pkgs.callPackage ./pkgs/applications/audio/zynaddsubfx {
    guiModule = "zest";
  };
}
