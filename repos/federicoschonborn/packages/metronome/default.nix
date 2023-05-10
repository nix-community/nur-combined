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
  version = "1.2.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Metronome";
    rev = version;
    hash = "sha256-rmqj8cXfbSnsgULvexG22myjJEcjfoymoNn3czKEvPY=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "cairo-rs-0.16.0" = "sha256-P0sJ06UGpZt6xawI2xI7dc8Oue2DjeRN6dfNLtDrAzA=";
      "gdk4-0.5.0" = "sha256-ba60f7JxjEPL/JEeXhQ7KRd8OAs8HdSoEMk9hp1kqD8=";
      "libadwaita-0.2.0" = "sha256-4Y1hBN4+paRl3Pn7md6YRbVfJqY/oooC1TW7XLGzO6M=";
    };
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
