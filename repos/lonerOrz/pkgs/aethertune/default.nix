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
  version = "0.12.0";

  # https://github.com/nevermore23274/AetherTune
  src = fetchFromGitHub {
    owner = "nevermore23274";
    repo = "AetherTune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oojRAsVe0wOQCHV19g9ZV2+QK7ibhy3ThroelF5PhxY=";
  };

  cargoHash = "sha256-L8vnzYqc5cfd8Vv2n1zA59LJmCci/5BxEocxJxQjpTI=";

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
