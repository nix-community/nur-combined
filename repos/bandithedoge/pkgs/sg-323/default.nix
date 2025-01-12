{
  pkgs,
  sources,
  utils,
  ...
}:
utils.juce.mkJucePackage {
  inherit (sources.sg-323) pname version src;

  meta = with pkgs.lib; {
    description = "Ursa Major Stargate 323 reverb emulation";
    homepage = "https://github.com/greyboxaudio/SG-323";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
