# nixpkgs' albert is marked Linux-only, and upstream's prebuilt macOS DMG
# is not self-contained (it hard-links Homebrew Qt at /opt/homebrew paths),
# so this builds albert from source against nix Qt6 by reusing the nixpkgs
# derivation and adapting its linux-isms for darwin. Needs a nixpkgs with
# albert 35.x (this flake pins nixpkgs-unstable): 33.x predates the source
# layout these patches target (35.x).
{
  lib,
  albert,
  kdePackages,
}:
(albert.override {
  kdePackages = kdePackages // {
    # qcoro is marked Linux-only in nixpkgs but builds fine on darwin
    qcoro = kdePackages.qcoro.overrideAttrs (o: {
      meta = o.meta // {
        platforms = o.meta.platforms ++ [ "aarch64-darwin" ];
      };
    });
  };
}).overrideAttrs
  (o: {
    # qtwayland is Linux-only
    buildInputs = lib.filter (p: (p.pname or "") != "qtwayland") o.buildInputs;
    # nixpkgs' cmake hook passes absolute install dirs, which albert's
    # bundle-macos.cmake concatenates onto the prefix ($out/$out/...)
    cmakeFlags = (o.cmakeFlags or [ ]) ++ [
      "-DCMAKE_INSTALL_LIBDIR=lib"
      "-DCMAKE_INSTALL_DATADIR=share"
    ];
    postPatch = o.postPatch + ''
      # the Homebrew include hint breaks the imported LibArchive target
      sed -i -e "\|/opt/homebrew|d" plugins/docs/CMakeLists.txt
      # bare codesign is not on PATH in the nix sandbox
      sed -i -e "s|COMMAND codesign|COMMAND /usr/bin/codesign|" cmake/bundle-macos.cmake.in
    '';
    postInstall = ''
      mkdir -p "$out/Applications"
      mv "$out/albert.app" "$out/Applications/Albert.app"
    '';
    # wrapQtAppsHook would wrap every Mach-O it finds, including the
    # framework binary and the plugin dylibs -- an executable wrapper is
    # not loadable by dyld/dlopen -- so only the main app binary is
    # wrapped, manually.
    dontWrapQtApps = true;
    postFixup = ''
      app="$out/Applications/Albert.app"
      wrapQtApp "$app/Contents/MacOS/Albert"
      # the executables link albert.framework at its pre-bundling install
      # path ($out/lib); point that path back at the bundled framework
      mkdir -p "$out/lib"
      ln -s "$app/Contents/Frameworks/albert.framework" "$out/lib/albert.framework"
      # re-sign innermost-first (--deep chokes on the framework layout);
      # stripping and wrapping invalidated the install-time signatures
      /usr/bin/codesign --force --sign - "$app/Contents/Frameworks/albert.framework/Versions/A"
      for p in "$app/Contents/PlugIns/albert/"*.dylib; do
        /usr/bin/codesign --force --sign - "$p"
      done
      /usr/bin/codesign --force --sign - "$app/Contents/MacOS/.Albert-wrapped"
      /usr/bin/codesign --force --sign - "$app"
    '';
    meta = o.meta // {
      platforms = [ "aarch64-darwin" ];
    };
  })
