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
  version = "0.1.0";

  # https://github.com/lonerOrz/pantry
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "pantry";
    rev = "e70a1d96ac3b54444120fa8968572bf1837f24d0";
    hash = "sha256-rf4/lDi+ZGGhCarbz7nGDBJsFcNbrdAG2cYX6W7zJ0I=";
  };

  cargoHash = "sha256-MjAxafWGbPHohPP1co1oL7UrSOGKEtisUe4fJj5fyiQ=";

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

  passthru.updateScript = ./update.sh;

  meta = {
    description = "generic selector tool for handling various types of entries with text and image preview modes";
    homepage = "https://github.com/lonerOrz/pantry";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "pantry";
  };
})
