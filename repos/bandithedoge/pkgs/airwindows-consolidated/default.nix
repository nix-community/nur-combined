{
  pkgs,
  sources,
  utils,
  ...
}:
utils.juce.mkJucePackage {
  inherit (sources.airwin2rack) src;
  pname = "airwindows-consolidated";
  version = sources.airwin2rack.date;

  buildInputs = with pkgs; [
    libjack2
  ];

  cmakeFlags = [
    "-DBUILD_JUCE_PLUGIN=TRUE"
    "-DCPM_LOCAL_PACKAGES_ONLY=TRUE"
    "-DCPM_JUCE_SOURCE=${sources.juce-7_0_12.src}"
    "-DCPM_clap-juce-extensions_SOURCE=${sources.clap-juce-extensions.src}"
  ];

  postPatch = ''
    cp ${pkgs.cpm-cmake}/share/cpm/CPM.cmake cmake/CPM.cmake
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib/clap,lib/lv2,lib/vst3}
    cp awcons-products/Airwindows\ Consolidated $out/bin/AirwindowsConsolidated
    cp awcons-products/Airwindows\ Consolidated.clap $out/lib/clap
    cp -r awcons-products/Airwindows\ Consolidated.lv2 $out/lib/lv2
    cp -r awcons-products/Airwindows\ Consolidated.vst3 $out/lib/vst3
  '';

  meta = with pkgs.lib; {
    description = "Airwindows, Consolidated into a single DAW Plugin";
    homepage = "https://github.com/baconpaul/airwin2rack";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
