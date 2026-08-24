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
  pname = "actuate";
  version = "1.4.5";
  src = fetchFromGitHub {
    owner = "ardura";
    repo = "Actuate";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TAabf0/Q2FwbNcW+KpJSNm5t4o7x8naNKdjiZURy4cg=";
  };

  cargoHash = "sha256-6yH7rYzxkTWC8eYp2FRQsF6TMYvoK6jiPCQOySn2RtQ=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libGL
    libx11
    libxcb
  ];

  postBuild = ''
    cargo xtask bundle Actuate --profile release
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,vst3}
    cp target/bundled/Actuate.clap $out/lib/clap
    cp -r target/bundled/Actuate.vst3 $out/lib/vst3

    runHook postInstall
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Synthesizer, Sampler, Granulizer written in Rust with Nih-Plug and egui";
    homepage = "https://github.com/ardura/Actuate";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
