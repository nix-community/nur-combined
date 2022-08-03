final: prev:

with final;

let
  callPackage = pkgs.newScope final;

  mapDisabledToBroken = attrs:
    (removeAttrs attrs [ "disabled" ]) // lib.optionalAttrs (attrs.disabled or false) {
      meta = (attrs.meta or {}) // {
        broken = attrs.disabled;
      };
    };

  pythonOverlay = pyfinal:
    import ./development/python-modules final (pyfinal // {
      buildPythonApplication = attrs: pyfinal.buildPythonApplication (mapDisabledToBroken attrs);
      buildPythonPackage = attrs: pyfinal.buildPythonPackage (mapDisabledToBroken attrs);
    });
in
{
  inherit callPackage;

  arctype = callPackage ./development/tools/database/arctype { };

  bcml = bcml-qt;

  bcml-gtk = python3Packages.callPackage ./games/bcml {
    gui = "gtk";
    wrapQtAppsHook = null;
    nodejs = nodejs-14_x;
  };

  bcml-qt = python3Packages.callPackage ./games/bcml {
    gui = "qt";
    inherit (qt5) wrapQtAppsHook;
    nodejs = nodejs-14_x;
  };

  caprine = callPackage ./applications/networking/instant-messengers/caprine {
    nodejs = nodejs-14_x;
  };

  ccache = callPackage ./development/tools/misc/ccache { };

  clonehero = clonehero-fhs-wrapper;
  clonehero-fhs-wrapper = callPackage ./games/clonehero/fhs-wrapper.nix { };
  clonehero-unwrapped = callPackage ./games/clonehero { };
  clonehero-xdg-wrapper = callPackage ./games/clonehero/xdg-wrapper.nix { };

  cmake-language-server = python3Packages.callPackage ./development/tools/misc/cmake-language-server {
    inherit cmake cmake-format;
  };

  gamemode = callPackage ./tools/games/gamemode rec {
    libgamemode32 = (pkgsi686Linux.callPackage ./tools/games/gamemode {
      inherit libgamemode32;
    }).lib;
  };

  git-review = python3Packages.callPackage ./applications/version-management/git-review { };

  goverlay = callPackage ./tools/graphics/goverlay {
    inherit (qt5) wrapQtAppsHook;
    inherit (plasma5Packages) breeze-qt5;
  };

  krane = callPackage ./applications/networking/cluster/krane { };

  lightdm-webkit2-greeter = callPackage ./applications/display-managers/lightdm-webkit2-greeter { };

  mangohud = callPackage ./tools/graphics/mangohud rec {
    libXNVCtrl = linuxPackages.nvidia_x11.settings.libXNVCtrl;
    mangohud32 = pkgsi686Linux.callPackage ./tools/graphics/mangohud {
      libXNVCtrl = linuxPackages.nvidia_x11.settings.libXNVCtrl;
      inherit mangohud32;
      inherit (pkgs.python3Packages) Mako;
    };
    inherit (pkgs.python3Packages) Mako;
  };

  mozlz4 = callPackage ./tools/compression/mozlz4 { };

  newsflash = callPackage ./applications/networking/feedreaders/newsflash { };

  poke = callPackage ./applications/editors/poke { };

  pokemmo-installer = callPackage ./games/pokemmo-installer {
    jre = jdk11;
    inherit (gnome) zenity;
  };

  protontricks = python3Packages.callPackage ./tools/package-management/protontricks {
    inherit steam-run yad;
  };

  python2Packages = recurseIntoAttrs (pythonOverlay (pkgs.python2Packages // python2Packages) pkgs.python2Packages);

  python3Packages = recurseIntoAttrs (pythonOverlay (pkgs.python3Packages // python3Packages) pkgs.python3Packages);

  replay-sorcery = callPackage ./tools/video/replay-sorcery { };

  runescape-launcher = callPackage ./games/runescape-launcher/fhsenv.nix { };

  texlab = callPackage ./development/tools/misc/texlab {
    inherit (darwin.apple_sdk.frameworks) Security CoreServices;
  };

  themes = recurseIntoAttrs (callPackage ./data/themes { });

  undistract-me = callPackage ./shells/bash/undistract-me { };

  virtualparadise = callPackage ./games/virtualparadise {
    inherit (qt5) wrapQtAppsHook;
  };

  vkBasalt = callPackage ./tools/graphics/vkBasalt rec {
    vkBasalt32 = pkgsi686Linux.callPackage ./tools/graphics/vkBasalt {
      inherit vkBasalt32;
    };
  };

  VVVVVV = callPackage ./games/VVVVVV/with-assets.nix {
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
}
