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
  version = "0-unstable-2026-10-04";

  # https://github.com/Immelancholy/Zarumet
  src = fetchFromGitHub {
    owner = "Immelancholy";
    repo = "Zarumet";
    rev = "1c9f1a1901266aec789bc8e938555a7f2c95f089";
    hash = "sha256-9tWZOc3RO6kovGtB6Mtk+X9+ppEpmQGFODx1aAzHhzc=";
  };

  cargoHash = "sha256-WsLLgWPT71Q4YQQAG5HQkeG1Ob6fvu41q/nIdoUlfDs=";

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
