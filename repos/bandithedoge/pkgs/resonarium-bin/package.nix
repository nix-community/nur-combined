{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
  unzip,
}:
stdenv.mkDerivation {
  inherit (sources.resonarium-bin) pname version;
  srcs = [
    sources.resonarium-bin.src
    sources.resonarium-effect-bin.src
  ];
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    mkdir -p $out/{bin,lib/vst3}
    cp Standalone/* $out/bin
    cp -r VST3/* $out/lib/vst3
  '';

  meta = {
    description = "An expressive, semi-modular, and comprehensive physical modeling/waveguide synthesizer";
    homepage = "https://github.com/gabrielsoule/resonarium";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Resonarium";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
