{ pkgs }:

let
  libkiwix_patched = pkgs.libkiwix.overrideAttrs (old: {
    __darwinAllowLocalNetworking = true;
    postPatch = (old.postPatch or "") + ''
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
    postPatch = (old.postPatch or "") + ''
      substituteInPlace kiwix-desktop.pro \
        --replace-warn "QMAKE_LFLAGS += -Wl,-rpath-link,\'\$\$PREFIX/lib/x86_64-linux-gnu\'" "" \
        --replace-warn "-Wl,-rpath-link,\'\$\$PREFIX/lib/x86_64-linux-gnu\'" ""
    '';
  })
