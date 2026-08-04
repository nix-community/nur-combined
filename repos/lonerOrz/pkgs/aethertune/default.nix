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
  version = "0.10.2";

  # https://github.com/nevermore23274/AetherTune
  src = fetchFromGitHub {
    owner = "nevermore23274";
    repo = "AetherTune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G7foHlCSojV5jz5XbQeplalZTaw2aZNh+hWZ0wTww48=";
  };

  cargoHash = "sha256-xArTVpcHHeh7T9016qWcbNWq0n99GbCRDUkGzVt2Vmo=";

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
