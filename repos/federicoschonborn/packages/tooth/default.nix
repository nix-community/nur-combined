{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook,
  gnome2,
  gtk4,
  json-glib,
  libadwaita,
  libgee,
  libsecret,
}:
stdenv.mkDerivation rec {
  pname = "tooth";
  version = "unstable-2023-03-07";

  src = fetchFromGitHub {
    owner = "GeopJr";
    repo = pname;
    rev = "6576a4e01806123d2d2ebf76ae6c7907efbe32e3";
    hash = "sha256-UfslVlBOkKmnJrFCLbdUGmJDrjgH+3LXbMdgGlojxlo=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    gnome2.libsoup
    gtk4
    json-glib
    libadwaita
    libgee
    libsecret
  ];

  meta = with lib; {
    description = "Browse the Fediverse";
    homepage = "https://github.com/GeopJr/Tooth";
    license = licenses.gpl3Plus;
  };
}
