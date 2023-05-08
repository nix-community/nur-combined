{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  gettext,
  gtk4,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  template-glib,
  vala,
  wrapGAppsHook4,
}:
stdenv.mkDerivation rec {
  pname = "elastic";
  version = "0.1.3";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "elastic";
    rev = version;
    hash = "sha256-CZ+EeGbCzkeNx4GD+2+n3jYwz/cQStjMV2+wm/JNsYU=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtksourceview5
    libadwaita
    template-glib
  ];

  meta = with lib; {
    description = "Design spring animations";
    homepage = "https://gitlab.gnome.org/World/elastic";
    mainProgram = "app.drey.Elastic";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
  };
}
