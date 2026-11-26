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

    # GIMP's macOS relocation support overwrites the wrapper's GDK pixbuf
    # loader cache with a path that does not exist in nixpkgs' split output.
    # Without SVG icon support this aborts while initializing the status bar.
    preFixup = (old.preFixup or "") + ''
      gappsWrapperArgs+=(--set GIMP_NO_WRAPPER 1)
    '';
  })
