{
  sources,

  lib,
  rustPlatform,

  libGL,
  libx11,
  libxcb,
  libxcb-wm,
  libxcursor,
  pkg-config,
  python3,
}:
rustPlatform.buildRustPackage {
  inherit (sources.octasine) pname src;
  version = lib.removePrefix "v" sources.octasine.version;
  cargoLock = sources.octasine.cargoLock."Cargo.lock";

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

  meta = {
    description = "Frequency modulation synthesizer plugin (VST2, CLAP).";
    homepage = "https://www.octasine.com/";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "octasine-cli";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
