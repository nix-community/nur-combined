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
famistudio.overrideAttrs (
  old:
  # Only touch the derivation on darwin, so the other platforms keep building
  # the exact same derivation as nixpkgs' famistudio.
  lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      copyDesktopItems
      desktopToDarwinBundle
    ];

    desktopItems = (old.desktopItems or [ ]) ++ [
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

    postInstall = (old.postInstall or "") + ''
      # desktopToDarwinBundle reads icons from the hicolor theme; upstream only
      # ships the .icns and the scalable source for it.
      install -Dm644 ${old.src}/FamiStudio/Resources/Icons/FamiStudio.svg \
        $out/share/icons/hicolor/scalable/apps/famistudio.svg
    '';
  }
)
