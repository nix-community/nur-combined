{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.peakeater-bin) pname src;
  version = lib.removePrefix "v" sources.peakeater-bin.version;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,lv2,vst3}
    cp Release/CLAP/peakeater.clap $out/lib/clap
    cp -r Release/LV2/peakeater.lv2 $out/lib/lv2
    cp -r Release/VST3/peakeater.vst3 $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "PeakEater is a free open-source cross-platform VST3/AU/LV2/CLAP wave shaper plugin";
    homepage = "https://github.com/vvvar/PeakEater";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
