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
    rev = "7e9d4cee4fd42cd25afda3e10712df20af78a72b";
    hash = "sha256-sKtpfCIhmt2HLM4RnP7fuvn9atl+4TxhwD4j67XmnaI=";
  };

  cargoHash = "sha256-YbtCgTuDx57OzETB/qFjIFhCJ+l7nv8h0iiBN56TjdU=";

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
