{ lib
, stdenv
, fetchFromGitLab
, cairo
, cargo
, desktop-file-utils
, gdk-pixbuf
, glib
, gst_all_1
, gtk4
, libadwaita
, meson
, ninja
, pango
, pkg-config
, rustc
, rustPlatform
, wrapGAppsHook4
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "metronome";
  version = "1.2.1";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Metronome";
    rev = finalAttrs.version;
    hash = "sha256-YQFS8JHd4SC0vNw6Lm3AN1nh5li8+Ep6lXJAUeUi4fo=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-ZRGq4lmpxDu/LXAXZTkoSixxBF3Ek2CduVNsPmDUN5Q=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
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
  };
})
