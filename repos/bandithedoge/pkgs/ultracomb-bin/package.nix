{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  libGL,
  libx11,
  libxcb,
}:
stdenv.mkDerivation {
  inherit (sources.ultracomb-bin) pname version src;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libGL
    libx11
    libxcb
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,vst3}
    cp Ultracomb.clap $out/lib/clap
    cp -r Ultracomb.vst3 $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "VST3/CLAP plugin that combines a flanger, phaser and frequency shifter to produce frequency notches that move around";
    homepage = "https://github.com/Wasaka0/ultracomb";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
