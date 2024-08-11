{
lib,
stdenv,
fetchFromGitea,
cargo,
meson,
ninja,
pkg-config,
rustPlatform,
rustc,
wrapGAppsHook4,
cairo,
gdk-pixbuf,
glib,
gtk4,
libadwaita,
libshumate,
pango,
sqlite,
darwin,
alsa-lib,
blueprint-compiler,
desktop-file-utils,
libxml2,
espeak
}:

stdenv.mkDerivation rec {
  pname = "jogger";
  version = "1.2.4";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "baarkerlounger";
    repo = "jogger";
    rev = version;
    hash = "sha256-CxK0pz7hSiknDJ7z5uI8uh/WZBucAeDx/MFNKgVQOuE=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "uom-0.35.0" = "sha256-8fbbmzozuDXBVUAVGc28BhcUaKtzgQoz/B6D426d/eY=";
    };
  };

  nativeBuildInputs = [
    cargo
    meson
    ninja
    pkg-config
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustc
    blueprint-compiler
    wrapGAppsHook4
    desktop-file-utils
    libxml2
    espeak
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    libshumate
    pango
    sqlite
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreAudio
    darwin.apple_sdk.frameworks.Security
  ] ++ lib.optionals stdenv.isLinux [
    alsa-lib
  ];

  meta = with lib; {
    description = "A run tracking app for Gnome Mobile";
    homepage = "https://codeberg.org/baarkerlounger/jogger";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "jogger";
    platforms = platforms.all;
  };
}
