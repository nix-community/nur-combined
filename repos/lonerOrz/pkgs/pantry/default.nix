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
  version = "0.3.0-unstable-2026-06-10";

  # https://github.com/lonerOrz/pantry
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "pantry";
    rev = "1dc9432403f21a9b72fcf4876432a512f2aa3fe9";
    hash = "sha256-K7sjtBFSLjOCBWFE6POfojOkQZHUFtxqgXbfgSvVWPQ=";
  };

  cargoHash = "sha256-El5neaHjzr0YuJg4k6TdA+wBCsnRrkXnx/3wPbUb+2Q=";

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
