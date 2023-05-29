{ lib
, stdenv
, fetchFromGitLab
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustPlatform
, cairo
, gdk-pixbuf
, glib
, gst_all_1
, gtk4
, libadwaita
, pango
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "metronome";
  version = "1.2.1";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Metronome";
    rev = version;
    hash = "sha256-YQFS8JHd4SC0vNw6Lm3AN1nh5li8+Ep6lXJAUeUi4fo=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "sha256-hako+hpm0lyQdq3xvW5zCWV6ONwjk8tTl+Z5fEpNNkU=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    gtk4
    libadwaita
    pango
  ];

  meta = with lib; {
    description = "Keep the tempo";
    homepage = "https://gitlab.gnome.org/World/Metronome";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
