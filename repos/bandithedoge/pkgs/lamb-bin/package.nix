{
  sources,

  lib,
  stdenv,

  alsa-lib,
  autoPatchelfHook,
  libGL,
  libx11,
  libxcb,
  libxcb-wm,
  unzip,
}:
stdenv.mkDerivation {
  inherit (sources.lamb-bin) pname src;
  version = lib.removePrefix "v" sources.lamb-bin.version;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    alsa-lib
    libGL
    libx11
    libxcb
    libxcb-wm
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/clap,lib/vst3}
    cp lamb $out/bin
    cp lamb.clap $out/lib/clap
    cp -r lamb.vst3 $out/lib/vst3

    runHook postInstall
  '';

  meta = {
    description = "A lookahead compressor/limiter that's soft as a lamb";
    homepage = "https://github.com/magnetophon/lamb-rs";
    license = lib.licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "lamb";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
