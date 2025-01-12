{
  pkgs,
  sources,
  utils,
  ...
}:
utils.juce.mkJucePackage {
  inherit (sources.rnnoise-plugin) pname version src;

  cmakeFlags = ["-DBUILD_FOR_RELEASE=ON"];

  installPhase = ''
    mkdir -p $out/lib/{lv2,vst3,vst,ladspa}
    cp -r src/juce_plugin/*_artefacts/Release/VST3/* $out/lib/vst3
    cp -r src/juce_plugin/*_artefacts/Release/LV2/* $out/lib/lv2
    cp src/juce_plugin/*_artefacts/Release/VST/* $out/lib/vst
    cp bin/ladspa/* $out/lib/ladspa
  '';

  meta = with pkgs.lib; {
    description = "Noise suppression plugin based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
