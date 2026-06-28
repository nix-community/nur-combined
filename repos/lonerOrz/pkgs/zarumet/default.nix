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
  version = "0-unstable-2026-06-28";

  # https://github.com/Immelancholy/Zarumet
  src = fetchFromGitHub {
    owner = "Immelancholy";
    repo = "Zarumet";
    rev = "e11910b16317295c326d99f287e21939f2d40b62";
    hash = "sha256-/o2wgONhytjktJiD7t6tLwiYxttpgugppfOLvhwo7Rs=";
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
