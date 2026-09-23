{
  lib,
  fetchFromGitLab,
  rustPlatform,
  autoPatchelfHook,
  capnproto,
  desktop-file-utils,
  mold,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  nettle,
  openssl,
  pcsclite,
  sqlite,
  wayland,
  libxkbcommon,
  libglvnd,
  rust-skia,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sequin";
  version = "0-unstable-2026-09-23";

  src = fetchFromGitLab {
    owner = "sequoia-pgp";
    repo = "Sequin";
    rev = "e1fb26e9762e231a865b39fff1d35be56c010fef";
    hash = "sha256-MwS5Imj5303pF0Dh4Sf1R3lmawrWK8tgJSVm7EgN4qQ=";
  };

  cargoHash = "sha256-fUIAxpYJc0VCL/VTDww1NzysUHLj6oX5rg7rWLM1ruE=";

  nativeBuildInputs = [
    autoPatchelfHook
    rustPlatform.bindgenHook
    wrapGAppsHook4
    capnproto
    desktop-file-utils
    mold
    pkg-config
  ];
  buildInputs = [
    gtk4
    libadwaita
    nettle
    openssl
    pcsclite
    sqlite
  ];
  runtimeDependencies = [
    libxkbcommon
    libglvnd
    wayland
  ];

  env.SKIA_BINARIES_URL = "file://${rust-skia}/skia-binaries.tar.gz";

  meta = {
    description = "Contact-centric PGP certificate manager built on Sequoia";
    homepage = "https://gitlab.com/sequoia-pgp/sequin";
    # sequin sources are LGPL-2.0-or-later, but uses Slint which requires GPL-3.0-only
    license = lib.licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "sequin";
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
