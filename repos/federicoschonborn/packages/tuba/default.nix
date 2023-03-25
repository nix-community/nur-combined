{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
  gnome,
  gtk4,
  json-glib,
  libadwaita,
  libgee,
  libsecret,
}:
stdenv.mkDerivation rec {
  pname = "tuba";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "GeopJr";
    repo = "Tuba";
    rev = "v${version}";
    hash = "sha256-dkURVzbDBrE4bBUvf2fPqvgLKE07tn7jl3OudZpEWUo=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gnome.libsoup
    gtk4
    json-glib
    libadwaita
    libgee
    libsecret
  ];

  meta = with lib; {
    description = "Browse the Fediverse";
    mainProgram = "dev.geopjr.Tuba";
    homepage = "https://github.com/GeopJr/Tuba";
    license = licenses.gpl3Plus;
  };
}
