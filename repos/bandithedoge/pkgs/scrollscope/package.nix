{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  alsa-lib,
  libGL,
  libjack2,
  libx11,
  libxcb,
  libxcb-wm,
  libxcursor,
  pkg-config,
  python3,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "scrollscope";
  version = "1.4.3";
  src = fetchFromGitHub {
    owner = "ardura";
    repo = "scrollscope";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mBnfH01b1/QM7z2KugV8mm6YM3xrTvyFIZ84PnSk3Do=";
  };

  cargoHash = "sha256-wCGc/qd1+1Tn9l1Zq1hQp5etDLvAdOaZfYoDX8fhMUw=";

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    alsa-lib
    libGL
    libjack2
    libx11
    libxcb
    libxcb-wm
    libxcursor
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/clap,lib/vst3}
    cargo xtask bundle scrollscope --profile release
    cp target/bundled/scrollscope $out/bin
    cp target/bundled/scrollscope.clap $out/lib/clap
    cp -r target/bundled/scrollscope.vst3 $out/lib/vst3

    runHook postInstall
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple scrolling oscilloscope in Rust";
    homepage = "https://github.com/ardura/Scrollscope";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "scrollscope";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
