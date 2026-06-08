{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  clang,
  pipewire,
  libclang,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "zarumet";
  version = "0-unstable-2026-06-07";

  # https://github.com/Immelancholy/Zarumet
  src = fetchFromGitHub {
    owner = "Immelancholy";
    repo = "Zarumet";
    rev = "7b7124849ab8b7d5e567a1215e49c85f774677a5";
    hash = "sha256-ulf13xnDzJZIw2D0N+X0+PT1cyGnija2sWVHgKlhXkU=";
  };

  cargoHash = "sha256-C9fMCltsovvqDvpfIeVUuxsJb4N/SVykDR7RrqmR/L0=";

  nativeBuildInputs = [
    pkg-config
    clang
  ];

  buildInputs = [ pipewire ];

  LIBCLANG_PATH = "${libclang.lib}/lib";

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Zarumet is an mpd client for the terminal written in Rust";
    homepage = "https://github.com/Immelancholy/Zarumet";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "zarumet";
  };
})
