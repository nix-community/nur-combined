{ chatty
, fetchFromGitLab
, appstream-glib
, desktop-file-utils
, itstool
, meson
, ninja
, pkg-config
, python3
# , wrapGAppsHook
# , evolution-data-server
, feedbackd
, glibmm
, gnome-desktop
, gspell
# , gtk3
, json-glib
, libgcrypt
, libhandy
, libphonenumber
, modemmanager
, olm
, pidgin
, protobuf
, sqlite
# NEW
, evolution-data-server-gtk4
, glib-networking
, gtk4
, libadwaita
, wrapGAppsHook4
}:
chatty.overrideAttrs (upstream: {
  pname = "chatty-latest";
  version = "unstable-2023-08-01";
  src = fetchFromGitLab {
    domain = "source.puri.sm";
    owner = "Librem5";
    repo = "chatty";
    rev = "ca556b7df539b37e08ed2c73e2beb2b6cc7b91f3";
    hash = "sha256-Tzdai2VU9wh/HW52uB+9uzpQymZmTqwiGqB6N20IvxE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    itstool
    meson
    ninja
    pkg-config
    python3
    #wrapGAppsHook

    # NEW
    wrapGAppsHook4
  ];

  buildInputs = [
    # evolution-data-server
    feedbackd
    glib-networking  # for TLS
    glibmm
    gnome-desktop
    gspell
    # gtk3
    json-glib
    libgcrypt
    libhandy
    libphonenumber
    modemmanager
    olm
    pidgin
    protobuf
    sqlite

    # NEW
    libadwaita
    gtk4
    evolution-data-server-gtk4
  ];
})
