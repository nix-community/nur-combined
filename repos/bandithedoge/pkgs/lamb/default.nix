{
  pkgs,
  sources,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  inherit (sources.lamb) pname version src;
  cargoLock = sources.lamb.cargoLock."Cargo.lock";

  nativeBuildInputs = with pkgs; [
    pkg-config
    python3
  ];

  buildInputs = with pkgs; [
    alsa-lib
    libGL
    libjack2
    xorg.libX11
    xorg.libXcursor
    xorg.libxcb
    xorg.xcbutilwm
  ];

  buildPhase = ''
    cargo xtask bundle lamb --release
  '';

  installPhase = ''
    mkdir -p $out/lib/{clap,vst3} $out/bin
    cp target/bundled/lamb $out/bin
    cp target/bundled/lamb.clap $out/lib/clap
    cp -r target/bundled/lamb.vst3 $out/lib/vst3
  '';

  meta = with pkgs.lib; {
    description = "A lookahead compressor/limiter that's soft as a lamb";
    homepage = "https://github.com/magnetophon/lamb-rs";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    broken = true; # weird rust dependency hash things happening
  };
}
