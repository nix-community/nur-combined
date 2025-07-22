{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  gettext,
  glib,
  gtk4,
  libadwaita,
  evolution-data-server,
  gst_all_1,
  callaudiod,
  desktop-file-utils,
  gsettings-desktop-schemas,
  wrapGAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "vvmplayer";
  version = "2.6";

  src = fetchFromGitLab {
    owner = "kop316";
    repo = "vvmplayer";
    rev = version;
    hash = "sha256-eSEXemihUDd3I3uxtIyfZJ5S5j9dXdv7w/D65TmNs6g=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    glib
    gtk4
    libadwaita
    evolution-data-server
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    callaudiod
    desktop-file-utils
    gsettings-desktop-schemas
    wrapGAppsHook
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gst_all_1.gst-libav
    callaudiod
  ];

  meta = with lib; {
    description = "Visual Voicemail Player";
    homepage = "https://gitlab.com/kop316/vvmplayer";
    license = licenses.gpl3Only;
    #maintainers = with maintainers; [ mich-adams ];
    mainProgram = "vvmplayer";
    platforms = platforms.all;
  };
}
