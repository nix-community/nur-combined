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
  wayland,
  breakpointHook,
}:
rustPlatform.buildRustPackage {
  pname = "polarity-sc-dark";
  version = "0-unstable-2026-05-22";
  src = fetchFromGitHub {
    owner = "polarity";
    repo = "plugin.nih.polarity-sc-dark";
    rev = "cc990a190545c515b590b05d5e0f4cdcae175b5b";
    hash = "sha256-7zMjjohOCZqvAEfppKOAEOgH3PtC31HaKP0cQwbEXYE=";
  };

  cargoHash = "sha256-JJ+AqWGiiYruB7VvXEJVPobI/ZfSSyL0eCm6z6Aab+Y=";

  nativeBuildInputs = [
    pkg-config
    python3
    breakpointHook
  ];

  buildInputs = [
    alsa-lib
    libGL
    libjack2
    libx11
    libxcb
    libxcb-wm
    libxcursor
    wayland
  ];

  postBuild = ''
    cargo xtask bundle polarity_sc_dark --release
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,vst3}
    cp target/bundled/Polarity-SC-Dark.clap $out/lib/clap
    cp -r target/bundled/Polarity-SC-Dark.vst3 $out/lib/vst3

    runHook postInstall
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Spectral Compressor with per-bin upward and downward compression, pink-noise shaping, sidechain spectral matching, freeze, and IR export";
    homepage = "https://polarity.productions/polarity-sc";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
