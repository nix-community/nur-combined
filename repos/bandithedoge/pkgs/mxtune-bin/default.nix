{
  pkgs,
  sources,
  utils,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.mxtune-bin) pname version src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  buildInputs = utils.juce.commonBuildInputs;

  buildPhase = ''
    mkdir -p $out/lib/vst
    cp mx_tune.so $out/lib/vst
  '';

  meta = with pkgs.lib; {
    description = "Pitch correction plugin for VST";
    homepage = "https://github.com/liuanlin-mx/MXTune";
    license = licenses.gpl3Only;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
