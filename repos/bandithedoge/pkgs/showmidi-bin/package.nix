{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.showmidi-bin) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,lib/clap,lib/lv2,lib/vst3}
    cp ShowMIDI $out/bin
    cp clap/ShowMIDI.clap $out/lib/clap
    cp -r lv2/ShowMIDI.lv2 $out/lib/lv2
    cp -r vst3/ShowMIDI.vst3 $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "Multi-platform GUI application to effortlessly visualize MIDI activity";
    homepage = "https://github.com/gbevin/ShowMIDI";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ShowMIDI";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
