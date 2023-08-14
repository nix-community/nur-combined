{ lib
, stdenv
, fetchFromGitLab
, desktop-file-utils
, gobject-introspection
, gst_all_1
, gtk4
, libadwaita
, meson
, ninja
, pkg-config
, vala
, wrapGAppsHook4
}:
stdenv.mkDerivation rec {
  pname = "g4music";
  version = "3.2";
  # version = "3.1";
  # version = "3.0";
  # version = "2.4";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "neithern";
    repo = "g4music";
    rev = "v${version}";
    hash = "sha256-BlHOYD4sOmJPNMzM5QA97Ah1N9tIat0Y6qxN6c5pmsw=";  # 3.2
    # hash = "sha256-U3STRCsc3xIVVQZcC3nKNNmyjANUUcFPep8yN36N3NY=";  # 3.1
    # hash = "sha256-Dg57BwEm6FNlXikQj1CfYovM5oIyhX2sM1G0FOdR6hU=";  # 3.0
    # hash = "sha256-y3G34NQEKPc145jLr98I6GaflzzgMVCCFLdcJDVkn8I=";  # 2.4
  };

  nativeBuildInputs = [
    desktop-file-utils  # for update-desktop-database
    gobject-introspection
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ] ++ (with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gstreamer
  ]);

  meta = with lib; {
    description = "A beautiful, fast, fluent, light weight music player written in GTK4";
    homepage = "https://gitlab.gnome.org/neithern/g4music";
    license = licenses.gpl3;
    maintainers = with maintainers; [ colinsane magnouvean ];
    platforms = platforms.linux;
  };
}
