{
  pkgs,
  sources,
  utils,
  ...
}:
utils.juce.mkJucePackage {
  inherit (sources.schrammel-ojd) pname src;
  version = sources.schrammel-ojd.date;

  nativeBuildInputs = with pkgs; [
    cargo
    rustPlatform.cargoSetupHook
  ];

  cargoRoot = "Ext/Resvg4JUCE/Ext/resvg";
  cargoDeps = pkgs.rustPlatform.importCargoLock sources.schrammel-ojd.cargoLock."Ext/Resvg4JUCE/Ext/resvg/Cargo.lock";

  meta = with pkgs.lib; {
    description = "Audio plugin model of a modern classic guitar overdrive Pedal";
    homepage = "https://schrammel.io/";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
