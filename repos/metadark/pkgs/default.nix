{ pkgs }:

pkgs.lib.fix (self:
let
  mergedPkgs = pkgs // self;
  callPackage = pkgs.newScope self;
in
with mergedPkgs; {
  inherit callPackage;

  bluetooth-autoconnect = python3Packages.callPackage ./tools/bluetooth/bluetooth-autoconnect { };

  caprine = callPackage ./applications/networking/instant-messengers/caprine {
    electron = electron_9;
  };

  clonehero = clonehero-fhs-wrapper;
  clonehero-fhs-wrapper = callPackage ./games/clonehero/fhs-wrapper.nix { };
  clonehero-unwrapped = callPackage ./games/clonehero { };
  clonehero-xdg-wrapper = callPackage ./games/clonehero/xdg-wrapper.nix { };

  cmake-language-server = python3Packages.callPackage ./development/tools/misc/cmake-language-server { };

  emacs-pgtk-nativecomp = callPackage ./applications/editors/emacs-pgtk-nativecomp { };

  git-review = python3Packages.callPackage ./applications/version-management/git-review { };

  goverlay = callPackage ./tools/graphics/goverlay { };

  libhandy1 = callPackage ./development/libraries/libhandy1 { };

  lightdm-webkit2-greeter = callPackage ./applications/display-managers/lightdm-webkit2-greeter { };

  newsflash = callPackage ./applications/networking/newsreaders/newsflash { };

  pokemmo-installer = callPackage ./games/pokemmo-installer {
    inherit (gnome3) zenity;
    jre = jdk11;
  };

  protontricks = python3Packages.callPackage ./tools/package-management/protontricks {
    inherit (gnome3) zenity;
    wine = wineWowPackages.minimal;
    winetricks = winetricks.override {
      wine = wineWowPackages.minimal;
    };
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

  rofi-wayland = callPackage ./applications/misc/rofi-wayland { };

  runescape-launcher-unwrapped = callPackage ./games/runescape-launcher { };
  runescape-launcher = callPackage ./games/runescape-launcher/wrapper.nix { };

  texlab = callPackage ./development/tools/misc/texlab {
    inherit (darwin.apple_sdk.frameworks) Security;
  };

  vkBasalt = callPackage ./tools/graphics/vkBasalt {
    vkBasalt32 = pkgsi686Linux.callPackage ./tools/graphics/vkBasalt { };
  };

  VVVVVV-unwrapped = callPackage ./games/VVVVVV {
    inherit (darwin.apple_sdk.frameworks) Foundation;
  };

  VVVVVV = callPackage ./games/VVVVVV/wrapper.nix {
    inherit (darwin.apple_sdk.frameworks) Foundation;
  };

  # wine-eac = callPackage ./misc/emulators/wine-eac {
  #   wineBuild =
  #     if stdenv.hostPlatform.system == "x86_64-linux"
  #     then "wineWow"
  #     else "wine32";
  # };

  xpadneo = callPackage ./os-specific/linux/xpadneo {
    kernel = linux;
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
})
