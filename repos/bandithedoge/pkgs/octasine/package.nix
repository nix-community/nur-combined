{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  libGL,
  libx11,
  libxcb,
  libxcb-wm,
  libxcursor,
  pkg-config,
  python3,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "octasine";
  version = "0.9.1";
  src = fetchFromGitHub {
    owner = "greatest-ape";
    repo = "OctaSine";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Vr1L5B7dF0pJieE/Zww/T6XbZadWMK5Fdq66qRfQFF0=";
  };

  cargoHash = "sha256-I+iZxngM8o4BIzjpowjf8l2m6MSY/NSSOd4TcYFjrIc=";

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    libGL
    libx11
    libxcb
    libxcb-wm
    libxcursor
  ];

  postBuild = ''
    cargo xtask bundle octasine --release --features "vst2"
    cargo xtask bundle octasine --release --features "clap"
  '';

  postInstall = ''
    mkdir -p $out/lib/vst $out/lib/clap
    cp target/bundled/octasine.so $out/lib/vst
    cp target/bundled/octasine.clap $out/lib/clap
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Frequency modulation synthesizer plugin (VST2, CLAP).";
    homepage = "https://www.octasine.com/";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "octasine-cli";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
