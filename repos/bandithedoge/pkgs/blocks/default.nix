{
  pkgs,
  sources,
  utils,
  ...
}:
utils.juce.mkJucePackage {
  inherit (sources.blocks) pname src;
  version = sources.blocks.date;

  meta = with pkgs.lib; {
    description = "User friendly cross platform modular synth";
    homepage = "https://www.soonth.com/";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
