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
  version = "0.1.0";

  # https://github.com/Immelancholy/Zarumet
  src = fetchFromGitHub {
    owner = "Immelancholy";
    repo = "Zarumet";
    rev = "b48333fbf00c16709dce90420c998b307525cdd2";
    hash = "sha256-RSlJO7ARZkiR5h+XiI+QLIa59DteMNakdD9HbSBqw9w=";
  };

  cargoHash = "sha256-V112dYRtbEAU8WoyUn5CfSLwOTrY/coIPkXXnBtNLmo=";

  nativeBuildInputs = [
    pkg-config
    clang
  ];

  buildInputs = [ pipewire ];

  LIBCLANG_PATH = "${libclang.lib}/lib";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Zarumet is an mpd client for the terminal written in Rust";
    homepage = "https://github.com/Immelancholy/Zarumet";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "zarumet";
  };
})
