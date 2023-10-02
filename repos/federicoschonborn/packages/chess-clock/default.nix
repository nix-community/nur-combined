{ lib
, python3Packages
, fetchFromGitLab
, desktop-file-utils
, gettext
, glib
, meson
, ninja
, wrapGAppsHook4
}:

python3Packages.buildPythonApplication rec {
  pname = "chess-clock";
  version = "0.6.0";

  format = "other";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "chess-clock";
    rev = "v${version}";
    hash = "sha256-wwNOop2V84vZO3JV0+VZ+52cKPx8xJg2rLkjfgc/+n4=";
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

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  meta = with lib; {
    description = "Time games of over-the-board chess";
    homepage = "https://gitlab.gnome.org/World/chess-clock";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
