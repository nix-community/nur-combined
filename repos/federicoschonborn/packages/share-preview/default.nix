{ lib
, stdenv
, fetchFromGitHub
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustPlatform
, cairo
, curl
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, openssl
, pango
, zlib
, darwin
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "share-preview";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "share-preview";
    rev = version;
    hash = "sha256-CsnWQxE2r+uWwuEzHpY/lpWS5i8OXvhRKvy2HzqnQ5U=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-H0IDKf5dz+zPnh/zHYP7kCYWHLeP33zHip6K+KCq4is=";
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
    curl
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    openssl
    pango
    zlib
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "Test social media cards locally";
    homepage = "https://github.com/rafaelmardojai/share-preview";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
