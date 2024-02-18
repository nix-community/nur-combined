{ stdenv
, lib
, fetchFromGitHub
, meson
, gettext
, glib
, gjs
, ninja
, gtk4
, webkitgtk
, gsettings-desktop-schemas
, wrapGAppsHook
, desktop-file-utils
, gobject-introspection
, glib-networking
, pkg-config
, appstream-glib
, adw-gtk3
, libadwaita
, webkitgtk_6_0
}:

stdenv.mkDerivation {
  pname = "foliate";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "johnfactotum";
    repo = "foliate";
    rev = "efddb107ae3c3a7c3acca73ad0c6a19981234e04";
    hash = "sha256-zvxNxpIRd6tZ+bd9c4BwaCVk3Genbo0SSU4rf0zFdBQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ meson ninja wrapGAppsHook pkg-config ];

  buildInputs = [
    gettext
    glib
    glib-networking
    gjs
    gtk4
    webkitgtk
    desktop-file-utils
    gobject-introspection
    gsettings-desktop-schemas
    appstream-glib
    libadwaita
    adw-gtk3
    webkitgtk_6_0
  ];

  meta = with lib; {
    description = "A simple and modern GTK eBook reader";
    homepage = "https://johnfactotum.github.io/foliate/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ onny ];
  };
}
