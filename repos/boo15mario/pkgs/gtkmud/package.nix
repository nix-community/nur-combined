{ lib
, python3Packages
, fetchFromGitHub
, wrapGAppsHook4
, gobject-introspection
, gtk4
, copyDesktopItems
, makeDesktopItem
}:

python3Packages.buildPythonApplication rec {
  pname = "gtkmud";
  version = "0.1.0-unstable";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "destructatron";
    repo = "gtkmud";
    rev = "413fcd08d4f997974f88378669b17499cbd08c8a";
    hash = "sha256-3U3O64CAg7p9AwnKNvAr/pXxa0+4B54iRWuZIIHMB0o=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
    copyDesktopItems
  ];

  buildInputs = [
    gtk4
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    lark
    aiohttp
    tomli-w
    setuptools
  ];

  postInstall = ''
    install -Dm644 ${./icon.svg} $out/share/icons/hicolor/scalable/apps/${pname}.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gtkmud";
      desktopName = "GTKMud";
      comment = "An accessible GTK4 MUD client with scripting support";
      exec = "gtkmud";
      icon = "gtkmud";
      categories = [ "Game" "RolePlaying" ];
    })
  ];

  meta = with lib; {
    description = "An accessible GTK4 MUD client with scripting support";
    homepage = "https://github.com/destructatron/gtkmud";
    license = licenses.mit;
    mainProgram = "gtkmud";
  };
}
