{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
}:
stdenv.mkDerivation rec {
  inherit (sources.squeezer-bin-standalone) pname version;
  srcs = with sources; [
    squeezer-bin-standalone.src
    squeezer-bin-vst2.src
  ];
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,lib/vst}

    cp squeezer-linux64-vst2_${version}/*.so $out/lib/vst
    cp -r squeezer-linux64-vst2_${version}/squeezer $out/lib/vst

    cp \
      squeezer-linux64-standalone_${version}/squeezer_mono_x64 \
      squeezer-linux64-standalone_${version}/squeezer_stereo_x64 \
      $out/bin
    cp -r squeezer-linux64-standalone_${version}/squeezer $out/bin

    runHook postBuild
  '';

  meta = {
    description = "Flexible general-purpose audio compressor with a touch of citrus";
    homepage = "https://github.com/mzuther/Squeezer";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "squeezer";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
