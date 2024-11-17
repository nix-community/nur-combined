{
  cargo,
  desktop-file-utils,
  fetchFromGitLab,
  glib,
  gtk4,
  lib,
  libadwaita,
  libsoup_3,
  meson,
  ninja,
  openssl,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  stdenv,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation {
  pname = "envelope";
  version = "0.1.0-unstable-2024-09-13";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "felinira";
    repo = "envelope";
    rev = "11ce86da13793787a25e48ca23322b33fcf8bf34";  # last commit before libadwaita 1.6
    hash = "sha256-EX309RhisBx27TscMsibEvqCSCUSukTgf4Xs1Vws4YY=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    python3
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    libsoup_3
    openssl
    webkitgtk_6_0
  ];

  postPatch = ''
    patchShebangs --build build-aux/meson-cargo-manifest.py
    # versions prior to c3f5ed4f (2024-10-13) didn't embed Cargo.lock
    cp ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "a mobile-first email client for the GNOME ecosystem";
    homepage = "https://gitlab.gnome.org/felinira/envelope/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.colinsane ];
    platforms = platforms.linux;
    mainProgram = "envelope";
  };
}
