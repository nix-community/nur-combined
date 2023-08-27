{ lib
, stdenv
, fetchFromGitHub
, cargo
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustPlatform
, rustc
, wrapGAppsHook4
, cairo
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, libxml2
, pango
}:

stdenv.mkDerivation rec {
  pname = "game-of-life";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "sixpounder";
    repo = "game-of-life";
    rev = "v${version}";
    hash = "sha256-vKZAFyM805EE4IEXa15hvXLGTa0P09V5stvvzOt/svU=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-vQsLqT9PGHPyUjsTQnXTrXohulKTo3bC5Eqtm3jMajE=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    libxml2
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    pango
  ];

  meta = with lib; {
    description = "A Conway's Game Of Life application for the gnome desktop";
    homepage = "https://github.com/sixpounder/game-of-life";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
