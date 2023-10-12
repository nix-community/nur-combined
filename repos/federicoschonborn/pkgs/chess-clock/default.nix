{ lib
, python3
, fetchFromGitLab
, desktop-file-utils
, gettext
, gobject-introspection
, meson
, ninja
, pkg-config
, wrapGAppsHook4
, gsound
, libadwaita
}:

python3.pkgs.buildPythonApplication rec {
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
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gsound
    libadwaita
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
  ];

  meta = with lib; {
    description = "Time games of over-the-board chess";
    homepage = "https://gitlab.gnome.org/World/chess-clock";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ federicoschonborn ];
    broken = versionOlder libadwaita.version "1.4";
  };
}
