{ pkgs }:

let
  libkiwix_patched = pkgs.libkiwix.overrideAttrs (old: {
    __darwinAllowLocalNetworking = true;
    postPatch =
      (old.postPatch or "")
      + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        substituteInPlace test/meson.build \
          --replace-fail "'server'," "" \
          --replace-fail "'library_server'," "" \
          --replace-fail "'server_search'" ""
      '';
  });
in
(pkgs.kiwix.override {
  libkiwix = libkiwix_patched;
}).overrideAttrs
  (old: {
    meta = (old.meta or { }) // {
      platforms = pkgs.lib.platforms.all;
    };
    patches = (old.patches or [ ]) ++ [ ../../../patches/kiwix-opds-url.patch ];
    postPatch =
      (old.postPatch or "")
      + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        substituteInPlace kiwix-desktop.pro \
          --replace-warn "QMAKE_LFLAGS += -Wl,-rpath-link,\'\$\$PREFIX/lib/x86_64-linux-gnu\'" "" \
          --replace-warn "-Wl,-rpath-link,\'\$\$PREFIX/lib/x86_64-linux-gnu\'" ""
      '';
    postInstall =
      (old.postInstall or "")
      + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        mkdir -p $out/bin/kiwix-desktop.app/Contents/Frameworks
        ln -s ${pkgs.qt6.qtwebengine}/lib/QtWebEngineCore.framework $out/bin/kiwix-desktop.app/Contents/Frameworks/QtWebEngineCore.framework
        ln -s $out/bin/kiwix-desktop.app/Contents/MacOS/kiwix-desktop $out/bin/kiwix-desktop
      '';
  })
