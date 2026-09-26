{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  libGL,
  libx11,
  libxcb,
  pkg-config,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "underbrush";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "ardura";
    repo = "underbrush";
    tag = "v${finalAttrs.version}";
    hash = "sha256-811Vur0Izxp7cSkYMplnJeW7yp9tSrMU9kQ3BLr/zu8=";
  };

  cargoHash = "sha256-IeAHwJedy4sxhiFhs5m6rGU7NN1aJ8n+4ctBAQ8UfDY=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libGL
    libx11
    libxcb
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,vst3}
    cargo xtask bundle underbrush --profile release
    cp target/bundled/underbrush.clap $out/lib/clap
    cp -r target/bundled/underbrush.vst3 $out/lib/vst3

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A few effects in a chain I like to use for coloring audio";
    homepage = "https://github.com/ardura/underbrush";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
