{
  slacky,
  lib,
  stdenv,
  desktopToDarwinBundle,
}:

# nixpkgs `slacky` is packaged as a Linux-only Electron app.  Electron itself is
# available on aarch64-darwin, so only the platform gate and the desktop
# integration need adjusting for Darwin.
slacky.overrideAttrs (old: {
  nativeBuildInputs =
    (old.nativeBuildInputs or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  postInstall =
    (old.postInstall or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # desktopToDarwinBundle looks for icons in the hicolor theme, not in
      # $out/share/icons directly as the upstream Linux install does.
      install -Dm644 $out/lib/node_modules/slacky/build/icons/icon.png \
        $out/share/icons/hicolor/512x512/apps/slacky.png
    '';

  meta = (old.meta or { }) // {
    platforms = (old.meta.platforms or [ ]) ++ [ "aarch64-darwin" ];
  };
})
