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
  version = "0.5.1";

  # https://github.com/nevermore23274/AetherTune
  src = fetchFromGitHub {
    owner = "nevermore23274";
    repo = "AetherTune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pHXjZzTx3GPbo9tV6RgFvvRWxy0p5o/5QLlOi6gcm2Y=";
  };

  cargoHash = "sha256-g8hiyFivHlRqArEhdCJgJ4fddmxryBZ6u1U70xatzMs=";

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
