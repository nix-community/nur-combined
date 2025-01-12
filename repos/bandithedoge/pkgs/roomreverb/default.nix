{
  pkgs,
  sources,
  utils,
  ...
}:
utils.juce.mkJucePackage {
  inherit (sources.roomreverb) pname version src;

  meta = with pkgs.lib; {
    description = "Room Reverb is a mono/stereo to stereo algorithmic reverb audio plugin with many presets that lets you add reverberation to your recordings in your DAW";
    homepage = "https://github.com/cvde/RoomReverb";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
