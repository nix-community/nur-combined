{ lib
, stdenv
, fetchFromGitLab
, blueprint-compiler
, desktop-file-utils
, gettext
, gtk4
, json-glib
, libadwaita
, libgee
, libportal-gtk4
, libsoup_3
, meson
, ninja
, pkg-config
, vala
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "damask";
  version = "0.1.5";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "subpop";
    repo = "damask";
    rev = "v${version}";
    hash = "sha256-gnN6A1AzAVbM5SwbwBOolX1b9j9DBV0jdwoREdM+EGc=";
  };

  nativeBuildInputs = [
    blueprint-compiler
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
    json-glib
    libadwaita
    libgee
    libportal-gtk4
    libsoup_3
  ];

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.gnome.org/subpop/damask";
    license = licenses.gpl3Only;
  };
}
