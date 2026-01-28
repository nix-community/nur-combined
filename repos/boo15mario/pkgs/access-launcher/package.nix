{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, gtk4
, wrapGAppsHook4
, copyDesktopItems
, makeDesktopItem
}:

rustPlatform.buildRustPackage rec {
  pname = "access-launcher";
  version = "0.4.3-unstable-2026-01-28";

  src = fetchFromGitHub {
    owner = "boo15mario";
    repo = "access-launcher";
    rev = "8b0973e1b6f579b173789e8b40f376a9c85fa319";
    hash = "sha256-a1POB7vKdNWerlRJeLlEPPXLhY8fODLUHclDOBNmtBQ=";
  };

  cargoHash = "sha256-9VU4AGBUOr5HZaSYfgNQIV7BJBmGoS9BW0osywAhuFc=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    copyDesktopItems
  ];

  buildInputs = [
    gtk4
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/512x512/apps
    mkdir -p $out/share/icons/hicolor/scalable/apps
    if [ -f assets/icon.png ]; then
      install -Dm644 assets/icon.png $out/share/icons/hicolor/512x512/apps/${pname}.png
    elif [ -f icon.png ]; then
      install -Dm644 icon.png $out/share/icons/hicolor/512x512/apps/${pname}.png
    elif [ -f access-launcher.svg ]; then
      install -Dm644 access-launcher.svg $out/share/icons/hicolor/scalable/apps/${pname}.svg
    else
      install -Dm644 ${./icon.svg} $out/share/icons/hicolor/scalable/apps/${pname}.svg
    fi
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "access-launcher";
      desktopName = "Access Launcher";
      comment = meta.description;
      exec = "access-launcher";
      icon = "access-launcher";
      categories = [ "Utility" ];
      startupNotify = true;
    })
  ];

  meta = with lib; {
    description = "A gtk4 based app launcher for linux";
    homepage = "https://github.com/boo15mario/access-launcher";
    license = licenses.mit; # TODO: Verify license
    mainProgram = "access-launcher";
  };
}
