{
  lib,
  stdenv,
  famistudio,
  copyDesktopItems,
  makeDesktopItem,
  desktopToDarwinBundle,
}:

# nixpkgs' famistudio builds the macOS (`FamiStudio.Mac`) target but installs
# only the .NET output, so there is no Finder-launchable bundle. Add a desktop
# entry and the upstream icon, then let desktopToDarwinBundle turn them into
# FamiStudio.app.
famistudio.overrideAttrs (old: {
  nativeBuildInputs =
    (old.nativeBuildInputs or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      copyDesktopItems
      desktopToDarwinBundle
    ];

  desktopItems =
    (old.desktopItems or [ ])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      (makeDesktopItem {
        name = "famistudio";
        desktopName = "FamiStudio";
        comment = "NES music editor";
        exec = "FamiStudio %f";
        icon = "famistudio";
        categories = [
          "AudioVideo"
          "Audio"
        ];
      })
    ];

  postInstall =
    (old.postInstall or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # desktopToDarwinBundle reads icons from the hicolor theme; upstream only
      # ships the .icns and the scalable source for it.
      install -Dm644 ${old.src}/FamiStudio/Resources/Icons/FamiStudio.svg \
        $out/share/icons/hicolor/scalable/apps/famistudio.svg
    '';
})
