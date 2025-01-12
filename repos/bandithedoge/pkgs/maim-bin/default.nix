{
  pkgs,
  sources,
  utils,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.maim-bin) pname version src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  buildInputs = utils.juce.commonBuildInputs;

  buildPhase = ''
    mkdir -p $out/lib/vst3
    cp -r Maim.vst3 $out/lib/vst3
  '';

  meta = with pkgs.lib; {
    description = "Audio plugin for custom MP3 distortion and digital glitches";
    homepage = "https://github.com/ArdenButterfield/Maim";
    license = licenses.gpl3Only;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
