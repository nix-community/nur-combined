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
    rev = "99ad6949ec5053a881a594345d1d9cf3fc073ee6";
    hash = "sha256-fT+C2IH0gs+QGuIaLvDPbxVXTDRD958Tc9mOSB91X2s=";
  };

  cargoHash = "sha256-j3ZibmKookg0d7J6cLeaGdPeGjEuS5u+g6B8xVCJ2ZY=";

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
