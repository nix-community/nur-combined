{
  sources,

  lib,
  rustPlatform,

  libGL,
  libx11,
  libxcb,
  pkg-config,
}:
rustPlatform.buildRustPackage {
  inherit (sources.actuate) pname src;
  version = lib.removePrefix "v" sources.actuate.version;
  cargoLock = sources.actuate.cargoLock."Cargo.lock";

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

  meta = {
    description = "Synthesizer, Sampler, Granulizer written in Rust with Nih-Plug and egui";
    homepage = "https://github.com/ardura/Actuate";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    # broken = true; # weird rust dependency hash things happening
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
