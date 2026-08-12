{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  mpv,
  libpulseaudio,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aethertune";
  version = "0.11.0";

  # https://github.com/nevermore23274/AetherTune
  src = fetchFromGitHub {
    owner = "nevermore23274";
    repo = "AetherTune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zrc0ko5HxOmrejHmwQOKfcEuckLHKdSXQrSJFwuKMHw=";
  };

  cargoHash = "sha256-U7n2HVaKWNLU6YMjIxlkDKr5BmMswiivbqKfPKyMlxQ=";

  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [
    mpv
    libpulseaudio
  ];

  meta = {
    description = "terminal-based internet radio player with real-time audio visualization, built in Rust";
    homepage = "https://github.com/nevermore23274/AetherTune";
    license = lib.licenses.mit;
    mainProgram = "AetherTune";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
