{
  pkgs,
  sources,
  utils,
  ...
}:
utils.juce.mkJucePackage {
  inherit (sources.ysfx) pname version src;

  cmakeFlags = [
    "-DFETCHCONTENT_SOURCE_DIR_JUCE=${sources.juce.src}"
    "-DYSFX_PLUGIN_COPY=FALSE"
    "-DYSFX_PLUGIN_LTO=ON"
  ];

  meta = with pkgs.lib; {
    description = "Hosting library for JSFX";
    homepage = "https://github.com/JoepVanlier/ysfx";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
