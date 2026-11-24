{
  lib,
  ryubing,
  stdenv,
  desktopToDarwinBundle,
}:

# nixpkgs' ryubing already covers the build. Only the darwin packaging differs:
# add desktopToDarwinBundle and install the desktop file and icon there too.
ryubing.overrideAttrs (old: {
  nativeBuildInputs =
    (old.nativeBuildInputs or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  preFixup =
    (old.preFixup or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/share/applications $out/share/icons/hicolor/scalable/apps
      cp ${old.src}/distribution/linux/Ryujinx.desktop $out/share/applications/Ryujinx.desktop
      substituteInPlace $out/share/applications/Ryujinx.desktop \
        --replace-warn "Exec=Ryujinx.sh %f" "Exec=Ryujinx"
      cp ${old.src}/distribution/misc/Logo.svg $out/share/icons/hicolor/scalable/apps/Ryujinx.svg
    '';
})
