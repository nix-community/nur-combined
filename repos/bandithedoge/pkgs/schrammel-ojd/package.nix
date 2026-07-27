{
  sources,

  lib,
  stdenv,

  cargo,
  juceCmakeHook,
  rustPlatform,
}:
stdenv.mkDerivation {
  inherit (sources.schrammel-ojd) pname src;
  version = sources.schrammel-ojd.date;

  nativeBuildInputs = [
    cargo
    juceCmakeHook
    rustPlatform.cargoSetupHook
  ];

  cargoRoot = "Ext/Resvg4JUCE/Ext/resvg";
  cargoDeps =
    rustPlatform.importCargoLock
      sources.schrammel-ojd.cargoLock."Ext/Resvg4JUCE/Ext/resvg/Cargo.lock";

  meta = {
    description = "Audio plugin model of a modern classic guitar overdrive Pedal";
    homepage = "https://schrammel.io/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
