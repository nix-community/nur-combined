final: prev:

with final;

let
  callPackage = prev.newScope final;

  emacsPackagesOverlay =
    import ./applications/editors/emacs/elisp-packages/manual-packages final;

  linuxModulesOverlay =
    if stdenv.isLinux
    then import ./os-specific/linux/modules.nix final
    else lfinal: lprev: { };

  mapDisabledToBroken = attrs:
    (removeAttrs attrs [ "disabled" ])
    // lib.optionalAttrs (attrs.disabled or false) {
      meta = (attrs.meta or { }) // {
        broken = attrs.disabled;
      };
    };

  removeFlakeRoot = path:
    lib.removePrefix "${toString ../.}/" path;

  fixUpdateScriptArgs = drv:
    drv // {
      updateScript =
        if builtins.isList drv.updateScript
        then [ (builtins.head drv.updateScript) ] ++ (builtins.map removeFlakeRoot (builtins.tail drv.updateScript))
        else drv.updateScript;
    };

  pythonModulesOverlay = pyfinal:
    import ./development/python-modules final (pyfinal // {
      buildPythonApplication = attrs: fixUpdateScriptArgs (pyfinal.buildPythonApplication (mapDisabledToBroken attrs));
      buildPythonPackage = attrs: fixUpdateScriptArgs (pyfinal.buildPythonPackage (mapDisabledToBroken attrs));
    });
in
{
  inherit callPackage;

  caprine = callPackage ./applications/networking/instant-messengers/caprine { };

  ccache = callPackage ./development/tools/misc/ccache { };

  clonehero = callPackage ./games/clonehero { };

  cmake-language-server = python3Packages.callPackage ./development/tools/misc/cmake-language-server {
    inherit cmake cmake-format;
  };

  emacsPackages = recurseIntoAttrs (emacsPackagesOverlay (prev.emacsPackages // emacsPackages) prev.emacsPackages);

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

  linuxPackages = recurseIntoAttrs (linuxModulesOverlay (prev.linuxPackages // linuxPackages) prev.linuxPackages);

  mangohud = callPackage ./tools/graphics/mangohud rec {
    libXNVCtrl = prev.linuxPackages.nvidia_x11.settings.libXNVCtrl;
    mangohud32 = pkgsi686Linux.callPackage ./tools/graphics/mangohud {
      libXNVCtrl = prev.linuxPackages.nvidia_x11.settings.libXNVCtrl;
      inherit mangohud32;
      inherit (prev.python3Packages) mako;
    };
    inherit (prev.python3Packages) mako;
  };

  mozlz4 = callPackage ./tools/compression/mozlz4 { };

  mozlz4a = callPackage ./tools/compression/mozlz4a { };

  newsflash = callPackage ./applications/networking/feedreaders/newsflash {
    webkitgtk = webkitgtk_6_0;
  };

  poke = callPackage ./applications/editors/poke { };

  pokemmo-installer = callPackage ./games/pokemmo-installer {
    inherit (gnome) zenity;
  };

  protontricks = python3Packages.callPackage ./tools/package-management/protontricks {
    steam-run = steamPackages.steam-fhsenv-without-steam.run;
    inherit bash winetricks yad;
  };

  python3Packages = recurseIntoAttrs (pythonModulesOverlay (prev.python3Packages // python3Packages) prev.python3Packages);

  replay-sorcery = callPackage ./tools/video/replay-sorcery { };

  rocfft = callPackage ./development/libraries/rocfft {
    inherit (llvmPackages_rocm) openmp;
    stdenv = rocmClangStdenv;
  };

  texlab = callPackage ./development/tools/misc/texlab {
    inherit (darwin.apple_sdk.frameworks) Security CoreServices;
  };

  themes = recurseIntoAttrs (callPackage ./data/themes { });

  undistract-me = callPackage ./shells/bash/undistract-me { };

  ukmm = callPackage ./tools/games/ukmm { };

  virtualparadise = callPackage ./games/virtualparadise {
    inherit (qt5) wrapQtAppsHook;
  };

  vkbasalt = callPackage ./tools/graphics/vkbasalt rec {
    vkbasalt32 = pkgsi686Linux.callPackage ./tools/graphics/vkbasalt {
      inherit vkbasalt32;
    };
  };

  yabridge = callPackage ./tools/audio/yabridge {
    wine = wineWowPackages.staging;
  };

  yabridgectl = callPackage ./tools/audio/yabridgectl {
    wine = wineWowPackages.staging;
  };

  zynaddsubfx = callPackage ./applications/audio/zynaddsubfx {
    guiModule = "zest";
    fftw = fftwSinglePrec;
  };

  zynaddsubfx-fltk = zynaddsubfx.override {
    guiModule = "fltk";
  };

  zynaddsubfx-ntk = zynaddsubfx.override {
    guiModule = "ntk";
  };
}
