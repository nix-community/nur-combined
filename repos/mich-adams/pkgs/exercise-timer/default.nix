{
  lib,
  stdenv,
  fetchFromGitHub,
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
  pango,
  darwin,
  alsa-lib,
  desktop-file-utils
}:

stdenv.mkDerivation rec {
  pname = "exercise-timer";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "mfep";
    repo = "exercise-timer";
    rev = "v${version}";
    hash = "sha256-wBc0yKtO/JRxi/EoAKeQtzwlSpO8oEaMjEDwexu7Wqw=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-AJ5e/z0TxXwQw531/kBEDdAWJgIWuKtsyEHGng/TPTg=";
  };

  nativeBuildInputs = [
    cargo
    meson
    ninja
    pkg-config
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    pango
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreAudio
  ] ++ lib.optionals stdenv.isLinux [
    alsa-lib
  ];

  meta = with lib; {
    description = "Timer app for high intensity interval training";
    homepage = "https://github.com/mfep/exercise-timer";
    changelog = "https://github.com/mfep/exercise-timer/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "exercise-timer";
    platforms = platforms.all;
  };
}
