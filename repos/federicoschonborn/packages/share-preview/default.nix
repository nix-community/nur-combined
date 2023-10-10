{ lib
, stdenv
, fetchFromGitHub
, cairo
, cargo
, curl
, darwin
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
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "share-preview";
    rev = finalAttrs.version;
    hash = "sha256-epN2YOaDrvdQwaUnIarnRTcHk5dhp6Ea29/37cliBes=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-tMb6zs5jJJyECDuAbzoOrB2H2/wPL8MEQOOWZ9rF66E=";
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
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Foundation
  ];

  meta = with lib; {
    description = "Test social media cards locally";
    homepage = "https://github.com/rafaelmardojai/share-preview";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ federicoschonborn ];
    broken = versionOlder version "23.11";
  };
})
