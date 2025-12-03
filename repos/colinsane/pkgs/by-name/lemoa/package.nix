{
  cargo,
  desktop-file-utils,
  fetchFromGitHub,
  gitUpdater,
  gtk4,
  lib,
  libadwaita,
  meson,
  ninja,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  stdenv,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "lemoa";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "lemmy-gtk";
    repo = "lemoa";
    rev = "v${version}";
    hash = "sha256-XyVl0vreium83d6NqiMkdER3U0Ra0GeAgTq4pyrZyZE=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-ALoxT+RLL4omJ7quWDJVdXgevaO8i8q/29FFFudIRV4=";
  };

  postPatch = ''
    substituteInPlace src/meson.build --replace-fail \
      "'target' / rust_target / meson.project_name()" \
      "'target' / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target / meson.project_name()"
  '';

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

  env.CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;

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
