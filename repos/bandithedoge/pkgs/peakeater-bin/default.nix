{
  pkgs,
  sources,
  utils,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.peakeater-bin) pname version src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  buildInputs = with pkgs;
    [
      stdenv.cc.cc.lib
    ]
    ++ utils.juce.commonBuildInputs;

  buildPhase = ''
    mkdir -p $out/lib/{clap,lv2,vst3}
    cp Release/CLAP/peakeater.clap $out/lib/clap
    cp -r Release/LV2/peakeater.lv2 $out/lib/lv2
    cp -r Release/VST3/peakeater.vst3 $out/lib/vst3
  '';

  meta = with pkgs.lib; {
    description = "PeakEater is a free open-source cross-platform VST3/AU/LV2/CLAP wave shaper plugin";
    homepage = "https://github.com/vvvar/PeakEater";
    license = licenses.gpl3;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
