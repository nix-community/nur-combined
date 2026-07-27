{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  csound6,
  juceCmakeHook,
  unzip,
}:
stdenv.mkDerivation {
  inherit (sources.tonez) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    csound6
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/vst3
    cp -r ToneZ_V2.vst3 $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "Free cross-platform polyphonic synthesizer";
    homepage = "https://www.retornz.com/plugins/tonez";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
