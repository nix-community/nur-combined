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
  version = "0.4.0-1";

  src = fetchFromGitHub {
    owner = "sixpounder";
    repo = "game-of-life";
    rev = "v${version}";
    hash = "sha256-R4hp/ZQzQ5o1jKYjrOy4HxZosYSYOnUS/QT9QjHu768=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-GVi0f6nzi7IfzNBbfPv4ystoXy6XstyjJDPw4+/7amw=";
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
