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
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sequin";
  version = "0-unstable-2026-10-08";

  src = fetchFromGitLab {
    owner = "sequoia-pgp";
    repo = "Sequin";
    rev = "078734053402bb0f8428404441b6c593beaf06dd";
    hash = "sha256-MRR3NNcgPUdNJqFyY+/WMxneWkFQQ/DuZXyGbtFaXrI=";
  };

  cargoHash = "sha256-u0IQe3TNA9U5dVGMOiDYr3fe7VTCClGyp8qiLPjY4F4=";

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

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

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
