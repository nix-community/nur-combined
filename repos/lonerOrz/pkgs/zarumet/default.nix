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
  version = "0-unstable-2026-06-21";

  # https://github.com/Immelancholy/Zarumet
  src = fetchFromGitHub {
    owner = "Immelancholy";
    repo = "Zarumet";
    rev = "de75d3802081f64f778a36051df31ba403e9eca4";
    hash = "sha256-WsgGD66x8PMO9oe0YM6Po5ihcRWf6+m/3a5CvDCNYh4=";
  };

  cargoHash = "sha256-FIjnwaTtXntgSPz1FAL2YguRIJqGbAi2X5HeF+0mhYQ=";

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
