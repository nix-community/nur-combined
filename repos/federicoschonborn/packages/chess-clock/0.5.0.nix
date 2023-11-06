{ lib
, python3Packages
, fetchFromGitLab
, desktop-file-utils
, gettext
, gobject-introspection
, meson
, ninja
, pkg-config
, wrapGAppsHook4
, libadwaita
}:

python3Packages.buildPythonApplication rec {
  pname = "chess-clock";
  version = "0.5.0";

  format = "other";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "chess-clock";
    rev = "v${version}";
    hash = "sha256-mmGJZ/TIa/5PfyDwg9gSamLpKUfw6+IvaPUmyIXcZII=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    mainProgram = "chess-clock";
    description = "Time games of over-the-board chess";
    homepage = "https://gitlab.gnome.org/World/chess-clock";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
