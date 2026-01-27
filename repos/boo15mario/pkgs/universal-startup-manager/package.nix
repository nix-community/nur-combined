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
  pname = "universal-startup-manager";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "boo15mario";
    repo = "universal-startup-manager";
    rev = "main";
    hash = "sha256-nrXMQQNrrXuVs+uzP17OPwdgcS97bQa1fdoW56Np6Ac=";
  };

  cargoHash = "sha256-Dr27mzPiSmkeTnmHTDgDnkmThq+AkZ6KFHoFf2645uk=";

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
    else
      install -Dm644 ${./icon.svg} $out/share/icons/hicolor/scalable/apps/${pname}.svg
    fi
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "universal-startup-manager";
      desktopName = "Universal Startup Manager";
      comment = meta.description;
      exec = "universal-startup-manager";
      icon = "universal-startup-manager";
      categories = [ "Utility" ];
      startupNotify = true;
    })
  ];

  meta = with lib; {
    description = "A universal startup manager for linux based on gtk4";
    homepage = "https://github.com/boo15mario/universal-startup-manager";
    license = licenses.mit; # TODO: Verify license
    mainProgram = "universal-startup-manager";
  };
}
