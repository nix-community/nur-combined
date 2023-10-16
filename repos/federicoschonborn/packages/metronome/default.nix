{ lib
, stdenv
, fetchFromGitLab
, cairo
, cargo
, darwin
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
  version = "1.3.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Metronome";
    rev = finalAttrs.version;
    hash = "sha256-Sn2Ua/XxPnJjcQvWeOPkphl+BE7/BdOrUIpf+tLt20U=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-HYO/IY5yGW8JLBxD/SZz16GFnwvv77kFl/x+QXhV+V0=";
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
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Foundation
  ];

  meta = {
    description = "Keep the tempo";
    homepage = "https://gitlab.gnome.org/World/Metronome";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
