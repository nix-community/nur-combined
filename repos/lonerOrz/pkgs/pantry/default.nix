{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  gtk4,
  glib,
  graphene,
  gdk-pixbuf,
  cairo,
  pango,
  harfbuzz,
  pkg-config,
  libiconv,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "pantry";
  version = "0.4.1-unstable-2026-07-09";

  # https://github.com/lonerOrz/pantry
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "pantry";
    rev = "a57b4f2c723ac1c5c0bc8b4776e3ff1488db6e33";
    hash = "sha256-3cevVhTPiozgIF7Z0izmEWNvSnpijNKYJ/pfxm7v0BA=";
  };

  cargoHash = "sha256-CmUk9F+X9NVNBJBDchqPVTgdtqW7UHsChPUwgN5Pv3M=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk4
    glib
    graphene
    gdk-pixbuf
    cairo
    pango
    harfbuzz
  ]
  ++ lib.optionals stdenv.isDarwin [
    # macOS-specific dependencies
    libiconv
  ];

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "generic selector tool for handling various types of entries with text and image preview modes";
    homepage = "https://github.com/lonerOrz/pantry";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "pantry";
  };
})
