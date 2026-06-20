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
  version = "0.3.2-unstable-2026-06-20";

  # https://github.com/lonerOrz/pantry
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "pantry";
    rev = "bb1820f762e7735a80ed743c24c0c14f20ea1688";
    hash = "sha256-YombhhYBGeo42zbBo9UM/xBwpHz+dwOxGEsTnFFB/i0=";
  };

  cargoHash = "sha256-skhSs1p6AnmUHSlA7CL3OgKHz+bIwc8/gqZfkixrpbQ=";

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
