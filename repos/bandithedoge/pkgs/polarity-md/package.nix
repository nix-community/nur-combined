{
  sources,

  lib,
  stdenv,
  autoPatchelfHook,
  unzip,
  juceCmakeHook,
  webkitgtk_4_1,
}:
stdenv.mkDerivation {
  inherit (sources.polarity-md) pname version src;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = juceCmakeHook.commonBuildInputs ++ [ webkitgtk_4_1 ];

  buildPhase = ''
    mkdir -p $out/{lib/clap,lib/vst3,bin}
    cp CLAP/Polarity-MD.clap $out/lib/clap
    cp -r VST3/Polarity-MD.vst3 $out/lib/vst3
    cp Standalone/Polarity-MD $out/bin

    patchelf --add-needed libwebkit2gtk-4.1.so \
      $out/lib/clap/Polarity-MD.clap \
      $out/lib/vst3/Polarity-MD.vst3/Contents/x86_64-linux/Polarity-MD.so \
      $out/bin/Polarity-MD
  '';

  meta = {
    description = "Four-band dynamics with upward + downward compression, per-band clipping";
    homepage = "https://polarity.productions/polarity-md/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Polarity-MD";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
