{ lib
, stdenv
, fetchFromGitLab
, desktop-file-utils
, gettext
, glib
, meson
, ninja
, pkg-config
, python3
, wrapGAppsHook4
}:

python3.pkgs.buildPythonApplication rec {
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
    meson
    ninja
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
  ];

  meta = with lib; {
    description = "Time games of over-the-board chess";
    homepage = "https://gitlab.gnome.org/World/chess-clock";
    license = licenses.gpl3Only;
  };
}
