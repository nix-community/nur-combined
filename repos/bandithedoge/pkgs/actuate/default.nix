{
  pkgs,
  sources,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  inherit (sources.actuate) pname version src;
  cargoLock = sources.actuate.cargoLock."Cargo.lock";

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    libGL
    xorg.libX11
  ];

  installPhase = ''
    mkdir -p $out/lib/{clap,vst3}
    cargo xtask bundle Actuate --profile release
    cp target/bundled/Actuate.clap $out/lib/clap
    cp -r target/bundled/Actuate.vst3 $out/lib/vst3
  '';

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Synthesizer, Sampler, Granulizer written in Rust with Nih-Plug and egui";
    homepage = "https://github.com/ardura/Actuate";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
