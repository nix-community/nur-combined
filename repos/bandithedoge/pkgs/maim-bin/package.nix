{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
  unzip,
}:
stdenv.mkDerivation {
  inherit (sources.maim-bin) pname version src;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,lib/vst3}
    cp Standalone/Maim $out/bin
    cp -r VST3/Maim.vst3 $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "Audio plugin for custom MP3 distortion and digital glitches";
    homepage = "https://github.com/ArdenButterfield/Maim";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Maim";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
