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
, libsecret
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
chatty.overrideAttrs (upstream: rec {
  pname = "chatty-latest";
  version = "v0.8.0_rc0";  # 2023-07-31
  src = fetchFromGitLab {
    domain = "source.puri.sm";
    owner = "Librem5";
    repo = "chatty";
    rev = version;
    hash = "sha256-dR6f9ZTAj1sXyoMmVyNog6XZthdZt9XrGFSi1KCRTcM=";
    fetchSubmodules = true;
  };

  postPatch = (upstream.postPatch or "") + ''
    substituteInPlace build-aux/meson/postinstall.py \
      --replace-fail 'gtk-update-icon-cache' 'gtk4-update-icon-cache'
  '';

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
    libsecret
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
