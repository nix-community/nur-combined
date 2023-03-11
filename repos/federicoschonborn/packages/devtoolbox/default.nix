{
  lib,
  python3,
  fetchFromGitHub,
  desktop-file-utils,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  gtksourceview5,
  libadwaita,
  webkitgtk_5_0,
  python-daltonlens,
  python-lorem,
  python-textstat,
  python-uuid6,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "devtoolbox";
  version = "1.0.2";

  format = "other";

  src = fetchFromGitHub {
    owner = "aleiepure";
    repo = "devtoolbox";
    rev = "v${version}";
    hash = "sha256-NirgCBZW/bgJz5sVioe3gmpDgOtqwxsFD9FMA8kb2Uw=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtksourceview5
    libadwaita
    webkitgtk_5_0
  ];

  pythonPath = with python3.pkgs; [
    croniter
    humanize
    lxml
    markdown2
    pygobject3
    python-crontab
    python-daltonlens
    python-jwt
    python-lorem
    python-textstat
    python-uuid6
    ruamel-yaml
    sqlparse
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Development tools at your fingertips";
    homepage = "https://github.com/aleiepure/devtoolbox";
    license = licenses.gpl3Plus;
  };
}
