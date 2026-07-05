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
  version = "0-unstable-2026-07-05";

  # https://github.com/Immelancholy/Zarumet
  src = fetchFromGitHub {
    owner = "Immelancholy";
    repo = "Zarumet";
    rev = "af91842ed7552eec3d20942baf81af9ad69b9ec2";
    hash = "sha256-92LMIITwVwmq1FAbRZ+DzVjfIC+fAVdpv0fEvKxWH6M=";
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
