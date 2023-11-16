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
, gsound
, libadwaita
, nix-update-script
}:

python3Packages.buildPythonApplication rec {
  pname = "chess-clock";
  version = "0.6.0";
  pyproject = false;

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

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Time games of over-the-board chess";
    homepage = "https://gitlab.gnome.org/World/chess-clock";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder libadwaita.version "1.4";
  };
}
