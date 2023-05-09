{ lib
, stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, rustPlatform
, cairo
, desktop-file-utils
, gdk-pixbuf
, glib
, gst_all_1
, gtk4
, libadwaita
, pango
, darwin
, wayland
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "snapshot";
  version = "44.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "Incubator";
    repo = "snapshot";
    rev = version;
    hash = "sha256-WnqTzq2MCJJz3EeCirwdHndxfLiLhkjfuXfl8pfg8wM=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-XffPDx7QMOeguiX7fLS5TzHVYdsoLTBoP3QC846pUH8=";
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
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gstreamer
    gtk4
    libadwaita
    pango
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
  ] ++ lib.optionals stdenv.isLinux [
    wayland
  ];

  meta = with lib; {
    description = "Take pictures and videos";
    homepage = "https://gitlab.gnome.org/Incubator/snapshot";
    license = licenses.gpl3Only;
  };
}
