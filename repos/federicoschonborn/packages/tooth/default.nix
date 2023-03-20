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
  gnome2,
  gtk4,
  json-glib,
  libadwaita,
  libgee,
  libsecret,
}:
stdenv.mkDerivation rec {
  pname = "tooth";
  version = "unstable-2023-03-20";

  src = fetchFromGitHub {
    owner = "GeopJr";
    repo = pname;
    rev = "f8e88dbcdcb90b57530366627bf60eaa25cc5439";
    hash = "sha256-8rdN5p2KAzCtmEhHdNZe2gvn9/kzQYWdE+Xhm0t4ndk=";
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
    gnome2.libsoup
    gtk4
    json-glib
    libadwaita
    libgee
    libsecret
  ];

  meta = with lib; {
    description = "Browse the Fediverse";
    mainProgram = "dev.geopjr.Tooth";
    homepage = "https://github.com/GeopJr/Tooth";
    license = licenses.gpl3Plus;
  };
}
