{
  lib,
  fetchFromGitLab,
  fetchurl,
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
  stdenv,
}:
let
  skiaTag = "0.99.0";
  skiaShortRev = "a25a0fdb7d90429aa2d1";
  skiaFeatures = "gl-jpegd-jpege-pdf-textlayout-vulkan";
  skiaKey = "${skiaShortRev}-${stdenv.hostPlatform.rust.rustcTarget}-${skiaFeatures}";
  skiaBinaries = fetchurl {
    url = "https://github.com/rust-skia/skia-binaries/releases/download/${skiaTag}/skia-binaries-${skiaKey}.tar.gz";
    hash =
      {
        "x86_64-linux" = "sha256-CX5413XJFW3EsHC5zKcAjbq1h1E+yxkkuvTPliDzEZs=";
        "aarch64-linux" = "sha256-/+Di4iETwO7laZGHlD4kvsi8hbE0ERAhAf7hMqyW9Cs=";
      }
      .${stdenv.hostPlatform.system};
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sequin";
  version = "0-unstable-2026-09-04";

  src = fetchFromGitLab {
    owner = "sequoia-pgp";
    repo = "Sequin";
    rev = "ec6f8b8eb0eedd2d41d1e0990ce25837ad49320b";
    hash = "sha256-5TUJFL+q+yHiNO/KbaW4+s06JBtcNDsWs3Imh7LqTBQ=";
  };

  cargoHash = "sha256-W8a37bUfPUW7ilyDq/9h1CQhxrg7q9T3+F+NCJ4hk+4=";

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

  env.SKIA_BINARIES_URL = "file://${skiaBinaries}";

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
