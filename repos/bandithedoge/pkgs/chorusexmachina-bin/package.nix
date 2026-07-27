{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  libGL,
  libx11,
  libxcb,
  unzip,
}:
stdenv.mkDerivation {
  inherit (sources.chorusexmachina-bin) pname src;
  version = lib.removePrefix "v" sources.chorusexmachina-bin.version;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    libGL
    libx11
    libxcb
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,vst3}
    cp chorus_ex_machina.clap $out/lib/clap
    cp -r chorus_ex_machina.vst3 $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "Chorus synthesizer";
    homepage = "https://github.com/peastman/ChorusExMachina";
    license = lib.licenses.lgpl21;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
