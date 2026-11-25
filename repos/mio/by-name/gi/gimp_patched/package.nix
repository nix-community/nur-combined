{
  lib,
  stdenv,
  gimp,
}:

# nixpkgs' GIMP lists only Linux in meta.platforms, even though upstream and the
# nixpkgs expression already have macOS code paths (desktopToDarwinBundle, the
# GDK OSX compile flag, ALSA/JavaScript disabled). It builds and its test suite
# passes on darwin; the one Linux-only input is XCursor, which upstream only
# uses for X11 custom cursors. Disable that feature on darwin and widen the
# platform list so the same derivation can be built here.
if !stdenv.hostPlatform.isDarwin then
  gimp
else
  gimp.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      platforms = lib.platforms.darwin;
    };

    mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Dxcursor=disabled" ];
  })
