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
  version = "0.5.0";

  # https://github.com/nevermore23274/AetherTune
  src = fetchFromGitHub {
    owner = "nevermore23274";
    repo = "AetherTune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lx7Ya+PFLHkfRuNHNayQKOSHLdtmY3BigDKme1H8QkA=";
  };

  cargoHash = "sha256-sTHrsQ/3tfiFd0TpaVBd6EaD+DHWLZaYjIZixw6VyhQ=";

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
