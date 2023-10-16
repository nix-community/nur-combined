{ lib
, stdenv
, fetchFromGitHub
, cairo
, cargo
, curl
, desktop-file-utils
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, meson
, ninja
, openssl
, pango
, pkg-config
, rustc
, rustPlatform
, wrapGAppsHook4
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "share-preview";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "share-preview";
    rev = finalAttrs.version;
    hash = "sha256-CsnWQxE2r+uWwuEzHpY/lpWS5i8OXvhRKvy2HzqnQ5U=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-H0IDKf5dz+zPnh/zHYP7kCYWHLeP33zHip6K+KCq4is=";
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
    curl
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    openssl
    pango
    zlib
  ];

  meta = {
    description = "Test social media cards locally";
    homepage = "https://github.com/rafaelmardojai/share-preview";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
