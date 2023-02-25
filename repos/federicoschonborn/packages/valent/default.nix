{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  desktop-file-utils,
  evolution-data-server,
  glib,
  gnutls,
  gst_all_1,
  json-glib,
  libadwaita,
  libpeas,
  libportal-gtk4,
  pulseaudio,
  sqlite,
}:
stdenv.mkDerivation rec {
  pname = "valent";
  version = "unstable-2023-02-24";

  src = fetchFromGitHub {
    owner = "andyholmes";
    repo = "valent";
    rev = "bd1126818bb8f123ceafc6a449cf26102f75293e";
    fetchSubmodules = true;
    sha256 = "sha256-YLvuPBaykeORLBj1cxT8KFYD02KaK3KuAKZNUf8QhMs=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    evolution-data-server
    glib
    gnutls
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    json-glib
    libadwaita
    libpeas
    libportal-gtk4
    pulseaudio
    sqlite
  ];

  mesonFlags = [
    "-Dplugin_bluez=true"
  ];

  meta = with lib; {
    description = "Connect, control and sync devices";
    homepage = "https://github.com/andyholmes/valent/";
    changelog = "https://github.com/andyholmes/valent/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [gpl3Plus cc0];
  };
}
