final: prev:

with final;

let
  callPackage = prev.newScope final;

  inherit (builtins)
    readDir;

  inherit (lib.attrsets)
    mapAttrsToList
    mergeAttrsList;

  # Package files for a single shard
  # Type: String -> String -> AttrsOf Path
  namesForShard = shard: type:
    if type != "directory" then
      # Ignore all non-directories. Technically only README.md is allowed as a file in the base directory, so we could alternatively:
      # - Assume that README.md is the only file and change the condition to `shard == "README.md"` for a minor performance improvement.
      #   This would however cause very poor error messages if there's other files.
      # - Ensure that README.md is the only file, throwing a better error message if that's not the case.
      #   However this would make for a poor code architecture, because one type of error would have to be duplicated in the validity checks and here.
      # Additionally in either of those alternatives, we would have to duplicate the hardcoding of "README.md"
      { }
    else
      builtins.mapAttrs
        (name: _: ./by-name + "/${shard}/${name}/package.nix")
        (readDir (./by-name + "/${shard}"));

  # The attribute set mapping names to the package files defining them
  # This is defined up here in order to allow reuse of the value (it's kind of expensive to compute)
  # if the overlay has to be applied multiple times
  packageFiles = mergeAttrsList (mapAttrsToList namesForShard (readDir ./by-name));

  autoCalledPackages = builtins.mapAttrs
    (name: file: callPackage file { })
    packageFiles;

  rocmPackgesOverlay = rfinal: rprev:
    builtins.mapAttrs
      # rocmUpdateScript isn't publicly exposed
      (name: drv: if drv ? updateScript then removeAttrs drv [ "updateScript" ] else drv)
      (import ./development/rocm-modules/5/default.nix final rfinal rprev);

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

  anytype = callPackage ./development/tools/misc/anytype {
    # electron_28 fails with: Process start error:  Error: spawn ENOTDIR
    electron = electron_27;
  };

  anytype-heart = callPackage ./development/libraries/anytype-heart { };

  ccache = callPackage ./by-name/cc/ccache/package.nix { };

  clonehero = clonehero-fhs-wrapper;
  clonehero-fhs-wrapper = callPackage ./games/clonehero/fhs-wrapper.nix { };
  clonehero-unwrapped = callPackage ./games/clonehero { };
  clonehero-xdg-wrapper = callPackage ./games/clonehero/xdg-wrapper.nix { };

  cmake-language-server = python3Packages.callPackage ./development/tools/misc/cmake-language-server {
    inherit cmake cmake-format;
  };

  emacsPackages = recurseIntoAttrs (emacsPackagesOverlay (prev.emacsPackages // emacsPackages) prev.emacsPackages);

  x = recurseIntoAttrs autoCalledPackages;

  gamemode = callPackage ./tools/games/gamemode rec {
    libgamemode32 = (pkgsi686Linux.callPackage ./tools/games/gamemode {
      inherit libgamemode32;
    }).lib;
  };

  ggt = callPackage ./development/tools/ggt { };

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
      libXNVCtrl = pkgsi686Linux.linuxPackages.nvidia_x11.settings.libXNVCtrl;
      inherit mangohud32;
      inherit (pkgsi686Linux.python3Packages) mako;
    };
    inherit (prev.python3Packages) mako;
  };

  mozlz4 = callPackage ./tools/compression/mozlz4 { };

  mozlz4a = callPackage ./tools/compression/mozlz4a { };

  newsflash = callPackage ./applications/networking/feedreaders/newsflash {
    webkitgtk = webkitgtk_6_0;
  };

  pdfrip = callPackage ./tools/security/pdfrip { };

  poke = callPackage ./applications/editors/poke { };

  pokemmo-installer = callPackage ./games/pokemmo-installer {
    inherit (gnome) zenity;
  };

  protoc-gen-js = callPackage ./development/tools/protoc-gen-js { };

  protontricks = python3Packages.callPackage ./tools/package-management/protontricks {
    steam-run = steamPackages.steam-fhsenv-without-steam.run;
    inherit winetricks yad;
  };

  python3Packages = recurseIntoAttrs (pythonModulesOverlay (prev.python3Packages // python3Packages) prev.python3Packages);

  replay-sorcery = callPackage ./tools/video/replay-sorcery { };

  rocmPackages = recurseIntoAttrs (rocmPackgesOverlay (prev.rocmPackages // rocmPackages) prev.rocmPackages);

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
