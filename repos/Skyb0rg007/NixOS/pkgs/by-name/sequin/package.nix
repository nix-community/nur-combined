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
  version = "0-unstable-2026-08-09";

  src = fetchFromGitLab {
    owner = "sequoia-pgp";
    repo = "Sequin";
    rev = "7b3ed4f63d5f4d3599ca5b9c94fbf172832a033c";
    hash = "sha256-7Fy43GJb5FSNWfojyjLzUkQcXdtn9uXXy+VLZHxior4=";
  };

  cargoHash = "sha256-cPeOy9C4bhKqIUTRv0HlcBq5Rc4nrJm/A8z5ohV2ZCc=";

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
