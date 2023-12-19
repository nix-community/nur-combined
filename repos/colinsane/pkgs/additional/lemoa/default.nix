{ lib, stdenv
, cargo
, desktop-file-utils
, fetchFromGitHub
, gdk-pixbuf
, gitUpdater
, glib
, graphene
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
}:

stdenv.mkDerivation rec {
  pname = "lemoa";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "lemmy-gtk";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kVyVU6GYxx4axype1VNfU8gh7ZoxJqkxwX9gCGQLPE8=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-efUFa77fIsGcvH0n82ITT4cgCkbowxZ/Y5rrIz0F3yQ=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];
  buildInputs = [
    gtk4
    libadwaita
    openssl
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Native Gtk client for Lemmy";
    homepage = "https://github.com/lemmy-gtk/lemoa";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ colinsane ];
  };
}
