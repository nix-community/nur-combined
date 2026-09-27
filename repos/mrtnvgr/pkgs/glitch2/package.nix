{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  alsa-lib,
  libx11,
  libxext,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "glitch2";
  version = "2.1.5";

  src = fetchzip {
    url = "https://illformed.com/downloads/Glitch_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}_Linux_Free.zip";
    hash = "sha256-cspn5blWQAW4urCo2nE0XvB3shxttT0bqrkFmsgRQMw=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    libx11
    libxext
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst3
    cp -r glitch2.vst3 $out/lib/vst3/glitch2.vst3

    mkdir -p $out/share/glitch2
    cp -r Glitch2_Presets $out/share/glitch2/presets

    runHook postInstall
  '';

  meta = {
    description = "Multi-effect glitch audio plugin with a layered sequencer and effects such as retrigger, stretcher, tape stop and more";
    homepage = "https://illformed.com/glitch/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
