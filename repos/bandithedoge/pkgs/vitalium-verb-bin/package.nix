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
  inherit (sources.vitalium-verb-bin) pname version src;

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

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,vst3}
    cp VitaliumVerb.clap $out/lib/clap
    cp -r VitaliumVerb.vst3 $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "A Rust port of the reverb module from the Vital/Vitalium synthesizer";
    homepage = "https://github.com/BillyDM/vitalium-verb";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
