{
  pkgs,
  sources,
  utils,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.showmidi-bin) pname version src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  buildInputs = with pkgs;
    [
      stdenv.cc.cc.lib
    ]
    ++ utils.juce.commonBuildInputs;

  buildPhase = ''
    mkdir -p $out/{bin,lib/clap,lib/lv2,lib/vst3}
    cp ShowMIDI $out/bin
    cp clap/ShowMIDI.clap $out/lib/clap
    cp -r lv2/ShowMIDI.lv2 $out/lib/lv2
    cp -r vst3/ShowMIDI.vst3 $out/lib/vst3
  '';

  meta = with pkgs.lib; {
    description = "Multi-platform GUI application to effortlessly visualize MIDI activity";
    homepage = "https://github.com/gbevin/ShowMIDI";
    license = licenses.gpl3Only;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
